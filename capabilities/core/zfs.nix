{
  config,
  lib,
  ...
}:
let
  cfg = config.host.zfs;
in
{
  options.host.zfs = {
    enable = lib.mkEnableOption "ZFS scrubbing and event notification" // {
      # Every host that actually has ZFS wants these; hosts without it get an
      # inert module. `boot.zfs.enabled` is upstream's readOnly summary of
      # "ZFS is in the initrd or in system.fsPackages", so this follows the
      # filesystem rather than needing a per-host opt-in.
      default = config.boot.zfs.enabled;
      defaultText = lib.literalExpression "config.boot.zfs.enabled";
    };

    notifyTokenFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/agenix/gotify-default";
      description = ''
        Path to a file holding the Gotify application token ZED posts with.
        Read at notification time rather than at build time, so the token
        never enters the Nix store. If the file is missing or empty, ZED's
        `zed_notify_gotify` returns without sending and the event is still
        recorded in the journal.
      '';
    };

    notifyUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://notify.grimaldifamily.org";
      description = ''
        Gotify base URL. ZED appends `/message?token=...` itself, so this is
        the bare origin with no path.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # A mirror or raidz that is never read end-to-end only tells you about
    # corruption when something happens to read the bad copy -- by which time
    # the redundancy that would have repaired it may already be gone. Scrub is
    # the only thing that walks every block while parity still exists.
    #
    # Monthly rather than the weekly upstream default because the pools this
    # fleet runs are large spinning arrays where a full pass takes hours and
    # competes with the host's real work. First Sunday at 03:00; hosts whose
    # workload wants a different hour override `interval` (see dunkirk).
    services.zfs.autoScrub = {
      enable = true;
      interval = lib.mkDefault "Sun *-*-01..07 03:00:00";
    };

    # Scrubbing without this is theatre: ZED already detects checksum errors,
    # degraded vdevs and failed scrubs, but ships with no delivery configured,
    # so it writes to the journal and nothing else. These hosts have no MTA,
    # which rules out ZED's email path -- but zed-functions.sh has had native
    # Gotify support since 2.1, so no wrapper script is needed.
    services.zfs.zed.settings = {
      ZED_GOTIFY_URL = cfg.notifyUrl;

      # zed.rc is sourced as shell by every zedlet (see the `. zed.rc` at the
      # top of e.g. statechange-notify.sh), so this substitution runs at
      # notification time. That matters: the generated zed.rc lands in the
      # world-readable Nix store, and an inlined token would be readable by
      # every user on the box and by anyone who gets the closure.
      #
      # The `|| true` keeps a missing secret from turning into a stderr spew on
      # every event -- an empty token makes zed_notify_gotify return 2 and the
      # event is still logged.
      ZED_GOTIFY_APPTOKEN = ''$(cat ${cfg.notifyTokenFile} 2>/dev/null || true)'';

      # Notify on successful scrubs too, not just failures. A monthly "scrub
      # finished, 0 errors" is the only evidence that this whole path still
      # works; without it a broken token looks exactly like a healthy pool.
      ZED_NOTIFY_VERBOSE = true;

      # Re-notify about a still-unhealthy vdev at most hourly, so a flapping
      # disk cannot bury everything else in the feed.
      ZED_NOTIFY_INTERVAL_SECS = 3600;
    };
  };
}
