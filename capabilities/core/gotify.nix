{
  config,
  lib,
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
