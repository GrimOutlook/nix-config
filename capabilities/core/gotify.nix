{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.gotify;
in
{
  options.host.gotify = {
    recipients = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "washington"
        "amsterdam"
        "dunkirk"
      ];
      description = ''
        Hosts whose SSH host key is a recipient of `secrets/gotify-default.age`.

        This has to stay in step with the `publicKeys` list for that entry in
        `secrets/secrets.nix`. Agenix fails *activation*, not evaluation, when
        it cannot decrypt -- so declaring the secret on a host that is not a
        recipient does not break the build, it breaks the switch, on the
        machine, after the closure is already there. Gating on a list that
        mirrors the recipients keeps that failure from being possible.

        newyork is deliberately absent and cannot simply be added. Its notify
        module derives one agenix secret per Gotify application by prefixing
        `gotify-`, so its application named `default` already claims this
        exact secret name for a *different* token -- newyork's own, posted
        over loopback rather than to the public origin. Enabling this
        capability there is a build-time conflict on
        `age.secrets.gotify-default.file` rather than a silent override, so
        the clash cannot pass unnoticed; resolving it means renaming a side.
      '';
    };

    tokenFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/agenix/gotify-default";
      description = ''
        Where the decrypted token lands. Consumers that cannot use
        `sender` below -- ZED, which does its own HTTP, and anything that
        must not take a package dependency -- read this path directly.
      '';
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "https://notify.grimaldifamily.org";
      description = ''
        Gotify origin, with no path. Unlike newyork's own senders, which
        post to loopback because Gotify runs there, everything using this
        goes over the network to the public name.
      '';
    };

    sender = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      defaultText = lib.literalMD "a `gotify-notify` script";
      description = ''
        `gotify-notify <priority> <title> <message>`.

        Exists so alert paths do not each carry their own copy of the same
        curl invocation. There were three such copies before this option --
        auditd's, mdadm's, and very nearly btrfs-scrub's -- and they had
        already drifted on retry behaviour.

        Never fails its caller. A missing or empty token is logged and
        skipped, because every consumer is an alert path attached to some
        other unit, and a notifier that fails is a monitored unit that
        reports failure for the wrong reason.
      '';
      default = pkgs.writeShellApplication {
        name = "gotify-notify";
        runtimeInputs = [ pkgs.curl ];
        text = ''
          if [ "$#" -ne 3 ]; then
            echo "usage: gotify-notify <priority> <title> <message>" >&2
            exit 2
          fi

          token_file=${lib.escapeShellArg cfg.tokenFile}
          if [ ! -r "$token_file" ]; then
            echo "gotify-notify: no token at $token_file, skipping: $2" >&2
            exit 0
          fi

          token="$(cat "$token_file")"
          if [ -z "$token" ]; then
            echo "gotify-notify: token at $token_file is empty, skipping: $2" >&2
            exit 0
          fi

          curl --silent --show-error --fail --output /dev/null \
            --max-time 10 --retry 3 --retry-delay 2 --retry-connrefused \
            --header "X-Gotify-Key: $token" \
            --form-string "title=$2" \
            --form-string "message=$3" \
            --form-string "priority=$1" \
            ${lib.escapeShellArg "${cfg.url}/message"} || \
            echo "gotify-notify: delivery failed, event not reported: $2" >&2
        '';
      };
    };

    enable = lib.mkEnableOption "the shared Gotify application token" // {
      default = builtins.elem config.networking.hostName cfg.recipients;
      defaultText = lib.literalExpression "builtins.elem config.networking.hostName config.host.gotify.recipients";
    };
  };

  config = lib.mkIf cfg.enable {
    # The Gotify application token that unattended, root-run alert paths post
    # with. Deliberately one shared token rather than one per consumer: these
    # are all "something is wrong with this machine" events that would be
    # muted or unmuted together anyway, and newyork already demonstrates the
    # cost of the other approach -- see the comment in its notify module about
    # renaming a token and losing two fail2ban bans before anyone noticed.
    #
    # Consumers, none of which can fall back to mail because these hosts have
    # no MTA:
    #   - ZED (./zfs.nix), for checksum errors, degraded vdevs, scrub results
    #   - mdadm --monitor on washington, for the degraded ESP mirror
    #   - auditd's admin_space_left_action (./hardening.nix)
    #
    # Left at the agenix defaults of root-owned 0400 because every one of
    # those runs as root; nothing here should be readable by a service user.
    age.secrets.gotify-default = {
      file = ../../secrets/gotify-default.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
