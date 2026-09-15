{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.host.btrfs;

  esc = utils.escapeSystemdPath;

  notifyScript = pkgs.writeShellScript "btrfs-scrub-notify" ''
    set -uo pipefail

    mountpoint="$(${pkgs.systemd}/bin/systemd-escape --unescape --path "$1")"
    host="$(${pkgs.nettools}/bin/hostname)"

    # Set by systemd for units started through OnSuccess=/OnFailure=.
    # "success" means `btrfs scrub start -B` exited 0; it exits non-zero when
    # the scrub found uncorrectable errors, which is the case that matters.
    result="''${MONITOR_SERVICE_RESULT:-unknown}"

    # The error counters live in the on-disk scrub status rather than in the
    # exit code, so report them either way -- a clean pass is the evidence
    # that this whole path still works.
    status="$(${pkgs.btrfs-progs}/bin/btrfs scrub status "$mountpoint" 2>&1 || true)"

    if [ "$result" != "success" ]; then
      priority="8"
      title="btrfs scrub FAILED on $host: $mountpoint"
    elif ! printf '%s' "$status" | ${pkgs.gnugrep}/bin/grep -q 'Status:[[:space:]]*finished'; then
      # The scrub unit cancels an in-progress scrub from ExecStop, so a
      # reboot part-way through still leaves the unit succeeding. Reporting
      # that as "clean" would be a lie of exactly the kind this notification
      # exists to prevent -- the pass covered only some of the filesystem.
      priority="5"
      title="btrfs scrub interrupted on $host: $mountpoint"
    else
      priority="2"
      title="btrfs scrub clean on $host: $mountpoint"
    fi

    ${config.host.gotify.sender}/bin/gotify-notify \
      "$priority" "$title" "$(printf 'systemd result: %s\n\n%s' "$result" "$status")"
  '';
in
{
  options.host.btrfs = {
    enable = lib.mkEnableOption "btrfs scrubbing and scrub notification" // {
      # Follows the filesystem, the way host.zfs follows boot.zfs.enabled.
      # There is no `boot.btrfs.enabled` equivalent to lean on, so this asks
      # config.fileSystems directly.
      default = lib.any (fs: fs.fsType == "btrfs") (lib.attrValues config.fileSystems);
      defaultText = lib.literalExpression ''lib.any (fs: fs.fsType == "btrfs") (lib.attrValues config.fileSystems)'';
    };
  };

  config = lib.mkIf cfg.enable {
    # Unlike a ZFS mirror, a single-device btrfs root cannot repair what a
    # scrub finds -- there is no second copy of the data to rebuild from
    # (metadata is DUP by default, data is not). So this is purely a detector:
    # its whole value is the report, which makes the notification below not an
    # optional extra but the reason for running it at all.
    #
    # Weekly, against upstream's monthly default and against the monthly
    # cadence host.zfs settles on. Those pools are large arrays where a pass
    # takes hours and competes with the host's real work; these are SSD roots
    # that finish in minutes, so there is nothing to schedule around and the
    # only thing frequency costs is the notification. For a filesystem that
    # can detect damage but not repair it, finding out sooner is the whole
    # benefit available.
    services.btrfs.autoScrub = {
      enable = true;
      interval = lib.mkDefault "weekly";
    };

    systemd.services = lib.mkMerge (
      # One template instantiated per filesystem rather than a single shared
      # unit: systemd coalesces concurrent triggers of the same unit, and the
      # MONITOR_* variables the script reads then describe whichever trigger
      # won the race.
      [
        {
          "btrfs-scrub-notify@" = {
            description = "report the result of btrfs scrub on %I";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${notifyScript} %i";
            };
          };
        }
      ]
      # Read back upstream's own list rather than recomputing it from
      # config.fileSystems: it dedupes filesystems mounted more than once and
      # subvolumes sharing a device, so a naive pass would attach notifiers to
      # scrub units that do not exist.
      ++ map (fs: {
        # Same unit name upstream derives in
        # nixos/modules/tasks/filesystems/btrfs.nix.
        "btrfs-scrub-${esc fs}" = {
          # Type=simple there, so ExecStartPost fires when the scrub *starts*.
          # These two are the only hooks that run when it finishes.
          onSuccess = [ "btrfs-scrub-notify@${esc fs}.service" ];
          onFailure = [ "btrfs-scrub-notify@${esc fs}.service" ];
        };
      }) config.services.btrfs.autoScrub.fileSystems
    );
  };
}
