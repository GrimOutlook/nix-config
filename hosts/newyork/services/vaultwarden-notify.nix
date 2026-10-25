{
  config,
  homelab,
  pkgs,
  ...
}:
let
  # This host's own LAN address, which is what vaultwarden reports when it has
  # no usable client address. See the note on `gateway` in the script below.
  gateway = homelab.networking.gateway;

  # The log collector lives on washington (VictoriaLogs, replacing the Loki
  # that used to run here -- see homelab/modules/logging.nix), so this reads
  # config.homelab.logging rather than any local collector config, and stays
  # correct regardless of which host runs it, now or if it moves again.
  victorialogs = "http://${config.homelab.logging.host}.${homelab.domains.local}:${toString config.homelab.logging.port}";

  # Both halves of vaultwarden's sign-in reporting come from vaultwarden itself:
  #
  #   [INFO]  User Example User logged in successfully. IP: 192.0.2.24
  #   [ERROR] Username or password is incorrect. Try again. IP: 1.2.3.4. Username: a@b.c
  #
  # Both name the account and carry an address that can be trusted, because the
  # `realip` snippet in caddy.nix overwrites X-Real-IP with the peer address.
  #
  # This replaces reading caddy's access log, which could only ever infer these.
  # Caddy sees status codes and never bodies, so it could not tell a wrong
  # password from the "two factor required" that vaultwarden also answers 400 to
  # on the password step of a *successful* login, and it could not tell a sign-in
  # from a token renewal except by pairing a 200 with a preceding `prelogin` --
  # the renewals dominate that endpoint, 723 response lines against 6 real
  # sign-ins. The lines above state both outright.
  #
  # Vaultwarden runs on washington, whose journal is already shipped to
  # VictoriaLogs (also on washington -- see `victorialogs` above) by the alloy agent in homelab/
  # modules/logging.nix. Querying VictoriaLogs over the network is what keeps this
  # unit on newyork: reading washington's journal directly would mean a
  # gotify sender, an agenix secret and an app token on a host that has none
  # of the three.
  vaultwarden-notify = pkgs.writeShellApplication {
    name = "vaultwarden-notify";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];
    text = ''
      notify="''${VAULTWARDEN_NOTIFY_CMD:-${config.notify.gotify.vaultwarden}/bin/gotify-notify-vaultwarden}"
      host=${config.networking.hostName}
      cursor=/var/lib/vaultwarden-notify/cursor

      # LogsQL compares _time against RFC3339, to nanosecond precision. Seeding
      # with the present on a first run is the same problem the journal
      # followers on this host have: without it the first query would return
      # everything VictoriaLogs still retains and report it all at once.
      # The second test reseeds a cursor left over from the Loki era, whose
      # contents were bare nanoseconds -- LogsQL rejects those outright
      # ("cannot parse duration"), so without it the unit would 400 forever.
      if [[ ! -s "$cursor" ]] || [[ "$(cat "$cursor")" != *T* ]]; then
        date -u +%Y-%m-%dT%H:%M:%S.%NZ > "$cursor"
      fi

      # Caddy overwrites X-Real-IP on every proxied request, so a client cannot
      # forge the address vaultwarden reports. For a small number of requests it
      # sends that header empty instead -- roughly eleven a fortnight, every one
      # I could correlate being HTTP/3, though sixty deliberate HTTP/3 requests
      # reproduced none, so the trigger is something narrower within it that I
      # could not pin down. Vaultwarden then falls back to the peer address,
      # which for a proxied request is caddy, which is this host.
      #
      # Reporting a sign-in as coming from the router is worse than admitting
      # the address is unknown, so the fallback is recognised and blanked. That
      # also drops the fail2ban line for such a failure, which is the honest
      # outcome: the address is not the client's and banning it would be
      # meaningless. The jail's ignoreip already covers this range, so nothing
      # was ever wrongly banned -- the attempt simply went uncounted, and still
      # does.
      gateway=${gateway}

      # A password guesser produces a run of failures, and one notification per
      # attempt would be the attack doing the paging. Only the gotify message is
      # rate limited -- the fail2ban line below is printed for every single
      # failure, because that is what the jail counts.
      declare -A reported=()

      while :; do
        # The cursor is advanced past the last line already seen rather than to
        # it. direction=forward keeps the order chronological, which is what
        # makes a cursor meaningful at all.
        # The cursor is read into a variable rather than substituted inline:
        # a $(<"...") inside the double-quoted --data-urlencode argument is
        # parsed as a fresh script, so the escaped quotes would land in the
        # filename and the query would go out with an empty _time.
        # The unit is pinned, not just the host: VictoriaLogs logs the text of
      # any query it rejects, so a malformed query containing this very
      # pattern would otherwise match itself on the next poll and report the
      # collector's own error line as a sign-in.
      start=$(cat "$cursor")
        query='host:=washington AND unit:=podman-vaultwarden.service AND _msg:~"logged in successfully|Username or password is incorrect" AND _time:>'"$start"' | sort by (_time) | fields _time, _msg | limit 100'

        if ! body=$(curl --silent --show-error --fail --max-time 20 \
              --get "${victorialogs}/select/logsql/query" \
              --data-urlencode "query=$query"); then
          # VictoriaLogs being unreachable must not advance the cursor, or
          # whatever happened during the outage is lost rather than delayed.
          sleep 30
          continue
        fi

        # Not @tsv: it escapes the entry's trailing newline to a literal `\n`,
        # which then sits between the last field and the end of the line and
        # defeats an anchored match on it. Folding real newlines to spaces and
        # trimming keeps one output line per entry with the message intact.
        # Sorting matters because the query's own result order is not
        # guaranteed and the cursor has to end on the newest line.
        while IFS=$'\t' read -r ts line; do
          [[ -n "$ts" ]] || continue

          now=$SECONDS
          for k in "''${!reported[@]}"; do
            if (( now - reported[$k] > 900 )); then unset 'reported[$k]'; fi
          done

          if [[ "$line" =~ User\ (.+)\ logged\ in\ successfully\.\ IP:\ ([0-9a-fA-F.:]+) ]]; then
            user="''${BASH_REMATCH[1]}"
            ip="''${BASH_REMATCH[2]}"
            if [[ "$ip" == "$gateway" ]]; then ip=""; fi

            "$notify" 5 "Vaultwarden login: $user" \
              "$user signed in to vaultwarden from ''${ip:-an address caddy did not report}, reported by vaultwarden on washington via $host." || true

          elif [[ "$line" =~ Username\ or\ password\ is\ incorrect ]]; then
            ip=""
            user=""
            if [[ "$line" =~ IP:\ ([0-9a-fA-F.:]+)\. ]]; then ip="''${BASH_REMATCH[1]}"; fi
            if [[ "$line" =~ Username:\ ([^[:space:]]+)\.$ ]]; then user="''${BASH_REMATCH[1]}"; fi
            if [[ "$ip" == "$gateway" ]]; then ip=""; fi

            # Printed for every failure, unconditionally: this is the line the
            # `vaultwarden` fail2ban jail matches on, and rate limiting it would
            # rate limit the ban. Keep the wording and the address position in
            # step with the filter in modules/services/fail2ban.
            if [[ -n "$ip" ]]; then
              printf 'vaultwarden auth failure from %s for %s\n' "$ip" "''${user:-unknown}"
            fi

            if [[ -z "''${reported[''${ip:-unknown}]:-}" ]]; then
              reported[''${ip:-unknown}]=$now
              "$notify" 7 "Vaultwarden login failed from ''${ip:-an unreported address}" \
                "A vaultwarden sign-in failed for ''${user:-an unnamed account} from ''${ip:-an address caddy did not report}, reported by vaultwarden on washington via $host. Further failures from this address are silent for 15 minutes." || true
            fi
          fi

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
  systemd.services.vaultwarden-notify = {
    description = "Notify gotify on vaultwarden sign-ins and failures reported by vaultwarden";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${vaultwarden-notify}/bin/vaultwarden-notify";
      # Runs as root: the gotify token is root-only. The cursor needs somewhere
      # durable to live across restarts.
      StateDirectory = "vaultwarden-notify";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
