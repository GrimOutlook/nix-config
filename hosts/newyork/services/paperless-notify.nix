{
  config,
  homelab,
  pkgs,
  ...
}:
let
  # This host's own LAN address. See the note on `gateway` in the script
  # below -- same fallback vaultwarden-notify.nix has, for the same reason.
  gateway = homelab.networking.gateway;

  # The log collector lives on washington (VictoriaLogs, replacing the Loki
  # that used to run here -- see homelab/modules/logging.nix), so this reads
  # config.homelab.logging rather than any local collector config, and stays
  # correct regardless of which host runs it, now or if it moves again.
  victorialogs = "http://${config.homelab.logging.host}.${homelab.domains.local}:${toString config.homelab.logging.port}";

  # Paperless-ngx itself only logs failed logins (src/paperless/signals.py).
  # The success half comes from a small Django app injected into the
  # container (hosts/washington/modules/services/paperless-ngx/login-notify-app),
  # which hooks user_logged_in and logs through the same "paperless.auth"
  # logger in a matching format:
  #
  #   [INFO] [paperless.auth] Login failed for user `admin` from private IP `10.1.0.33`.
  #   [INFO] [paperless.auth] Login successful for user `admin` from private IP `192.0.2.24`.
  #
  # Both name the account, which is why this reads paperless' own log instead
  # of caddy's access log (as web-login-notify.nix does for the services whose
  # login endpoint is a bare status code) -- caddy never sees the username.
  #
  # Paperless runs on washington, whose journal is already shipped to
  # VictoriaLogs (also on washington -- see `victorialogs` above) by the alloy agent (homelab/
  # modules/logging.nix), so this follows vaultwarden-notify.nix's shape
  # rather than reading washington's journal directly.
  paperless-notify = pkgs.writeShellApplication {
    name = "paperless-notify";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];
    text = ''
      notify="''${PAPERLESS_NOTIFY_CMD:-${config.notify.gotify.paperless}/bin/gotify-notify-paperless}"
      host=${config.networking.hostName}
      cursor=/var/lib/paperless-notify/cursor
      gateway=${gateway}

      # A password guesser produces a run of failures, and one notification
      # per attempt would be the attack doing the paging. Successes are not
      # rate limited -- a real sign-in is a single event, not a run.
      declare -A reported=()

      # One line in, at most one notify call out. Split out so the parsing
      # and the notify invocation -- the part worth testing -- don't require
      # a live VictoriaLogs/gotify to exercise; see the flake check in flake.nix,
      # which feeds this fixture lines with PAPERLESS_NOTIFY_CMD stubbed out.
      process_line() {
        local line=$1

        local kind user
        if [[ "$line" =~ Login\ (failed|successful)\ for\ user\ \`([^\`]+)\` ]]; then
          kind="''${BASH_REMATCH[1]}"
          user="''${BASH_REMATCH[2]}"
        else
          return
        fi

        local ip=""
        if [[ "$line" =~ \ from\ (private\ )?IP\ \`([0-9a-fA-F.:]+)\` ]]; then
          ip="''${BASH_REMATCH[2]}"
        fi
        # A single-hop proxied request whose X-Real-IP paperless didn't trust
        # falls back to the peer address, which for anything going through
        # caddy is this host. That is not the client's address, so it is
        # blanked rather than reported as one -- same reasoning as
        # vaultwarden-notify.nix's `gateway` check.
        if [[ "$ip" == "$gateway" ]]; then ip=""; fi

        if [[ "$kind" == successful ]]; then
          "$notify" 5 "Paperless login: $user" \
            "$user signed in to paperless-ngx from ''${ip:-an address paperless did not report}, reported by paperless on washington via $host." || true
          return
        fi

        # kind == failed
        local now=$SECONDS
        for k in "''${!reported[@]}"; do
          if (( now - reported[$k] > 900 )); then unset 'reported[$k]'; fi
        done

        local key=''${ip:-$user}
        if [[ -z "''${reported[$key]:-}" ]]; then
          reported[$key]=$now
          "$notify" 7 "Paperless login failed: $user" \
            "A paperless-ngx sign-in failed for $user from ''${ip:-an address paperless did not report}, reported by paperless on washington via $host. Further failures for this address or user are silent for 15 minutes." || true
        fi
      }

      # Test seam: feed canned `ts\tline` pairs from a file instead of
      # polling VictoriaLogs, and run once instead of forever. Used only by the
      # `paperless-notify-test` flake check.
      if [[ -n "''${PAPERLESS_NOTIFY_TEST_FILE:-}" ]]; then
        while IFS=$'\t' read -r _ts line; do
          [[ -n "$line" ]] || continue
          process_line "$line"
        done < "$PAPERLESS_NOTIFY_TEST_FILE"
        exit 0
      fi

      # LogsQL compares _time against RFC3339, to nanosecond precision.
      # Seeding with the present on a first run keeps the first query from
      # returning everything VictoriaLogs still retains and reporting it all
      # at once.
      # The second test reseeds a cursor left over from the Loki era, whose
      # contents were bare nanoseconds -- LogsQL rejects those outright
      # ("cannot parse duration"), so without it the unit would 400 forever.
      if [[ ! -s "$cursor" ]] || [[ "$(cat "$cursor")" != *T* ]]; then
        date -u +%Y-%m-%dT%H:%M:%S.%NZ > "$cursor"
      fi

      while :; do
        # `_time:>` is strict, so the last line already seen is excluded
        # rather than repeated. /select/logsql/query answers with NDJSON in
        # no guaranteed order, hence the sort below.
        # The cursor is read into a variable rather than substituted inline:
        # a $(<"...") inside the double-quoted --data-urlencode argument is
        # parsed as a fresh script, so the escaped quotes would land in the
        # filename and the query would go out with an empty _time.
        # The unit is pinned, not just the host: VictoriaLogs logs the text of
      # any query it rejects, so a malformed query containing this very
      # pattern would otherwise match itself on the next poll and report the
      # collector's own error line as a sign-in.
      start=$(cat "$cursor")
        query='host:=washington AND unit:=podman-paperless.service AND _msg:~"Login (failed|successful) for user" AND _time:>'"$start"' | sort by (_time) | fields _time, _msg | limit 100'

        if ! body=$(curl --silent --show-error --fail --max-time 20 \
              --get "${victorialogs}/select/logsql/query" \
              --data-urlencode "query=$query"); then
          # VictoriaLogs being unreachable must not advance the cursor, or
          # whatever happened during the outage is lost rather than delayed.
          sleep 30
          continue
        fi

        # Not @tsv: it escapes the entry's trailing newline to a literal
        # `\n`, which then sits between the last field and the end of the
        # line and defeats an anchored match on it. Sorting matters because
        # the query's own result order is not guaranteed and the cursor has
        # to end on the newest line.
        while IFS=$'\t' read -r ts line; do
          [[ -n "$ts" ]] || continue
          process_line "$line"
          printf '%s\n' "$ts" > "$cursor"
        done < <(jq -rs '
          sort_by(._time)
          | .[]
          | "\(._time)\t\((._msg // "") | gsub("\n"; " ") | sub("\\s+$"; ""))"
        ' <<<"$body")

        sleep 15
      done
    '';
  };
in
{
  systemd.services.paperless-notify = {
    description = "Notify gotify on paperless-ngx sign-ins and failures reported by paperless";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${paperless-notify}/bin/paperless-notify";
      # Runs as root: the gotify token is root-only. The cursor needs
      # somewhere durable to live across restarts.
      StateDirectory = "paperless-notify";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
