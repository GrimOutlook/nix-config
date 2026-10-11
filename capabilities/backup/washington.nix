{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  state = "/var/lib/washington-backup";
  repository = "/vault/backups/washington";
  mirror = "/vault/mirrors/washington";
  notify = pkgs.writeShellApplication {
    name = "washington-backup-notify";
    text = ''
      job="$1"
      result="''${MONITOR_SERVICE_RESULT:-unknown}"
      exit_code="''${MONITOR_EXIT_CODE:-unknown}"
      exit_status="''${MONITOR_EXIT_STATUS:-unknown}"
      # A manually stopped oneshot may have result=success but was killed,
      # so only a normal zero exit is a successful completed backup.
      if [ "$result" = success ] && [ "$exit_code" = exited ] && [ "$exit_status" = 0 ]; then
        priority=2
        outcome=succeeded
      else
        priority=8
        outcome=FAILED
      fi
      ${config.host.gotify.sender}/bin/gotify-notify "$priority" \
        "Washington $job $outcome on ${config.networking.hostName}" \
        "Job: washington-$job.service. Host: ${config.networking.hostName}. Result: $result. Exit: $exit_code/$exit_status. Repository: ${repository}. See journalctl -u washington-$job.service for details."
    '';
  };
  pull = pkgs.writeShellApplication {
    name = "washington-backup-pull";
    runtimeInputs = [
      pkgs.openssh
      pkgs.restic
      pkgs.coreutils
      pkgs.rsync
      pkgs.util-linux
    ];
    text = ''
      export RESTIC_REPOSITORY=${repository}
      export RESTIC_PASSWORD_FILE=${config.age.secrets.washington-restic-password.path}
      exec 9>${state}/operation.lock
      flock 9
      export RSYNC_RSH="ssh -T -i ${config.age.secrets.washington-backup-ssh-key.path} -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=${state}/known_hosts -o ConnectTimeout=30 -o ServerAliveInterval=30 -o ServerAliveCountMax=3"
      install -d -m 0700 ${mirror}/storage ${mirror}/snapshots
      for module in vaultwarden paperless mail-archive immich; do
        rsync -aH --rsh="$RSYNC_RSH" --numeric-ids --delete-delay --partial-dir=.rsync-partial --stats \
          ${lib.escapeShellArg "backup@${config.host.backup.washington.address}::"}"$module/" ${mirror}/storage/"$module/"
      done
      rsync -aH --rsh="$RSYNC_RSH" --numeric-ids --delete-delay --partial-dir=.rsync-partial --stats \
        --rsync-path=washington-snapshots \
        ${lib.escapeShellArg "backup@${config.host.backup.washington.address}::snapshots/"} ${mirror}/snapshots/
      if [ ! -f "$RESTIC_REPOSITORY/config" ]; then
        restic init
      fi
      # Only a fully successful transfer reaches Restic; retain partials for retry.
      cd ${mirror}
      restic backup --host washington --tag incremental --exclude .rsync-partial storage snapshots
    '';
  };
in
{
  options.host.backup.washington.address = lib.mkOption {
    type = lib.types.str;
    default = "washington.${inputs.homelab.domains.local}";
    description = "Washington SSH endpoint reachable from this backup host (LAN or VPN).";
  };
  options.host.backup.washington.calendar = lib.mkOption {
    type = lib.types.str;
    description = "Required calendar schedule for pulling Washington backups; set on each backup host.";
  };
  config = lib.mkIf config.host.backup.enable {
    age.secrets.washington-backup-ssh-key = {
      file = ./secrets/washington-ssh-key.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
    age.secrets.washington-restic-password = {
      file = ./secrets/washington-restic-password.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
    environment.systemPackages = [ pkgs.restic ];
    systemd.tmpfiles.rules = [ "d ${state} 0700 root root -" ];
    systemd.services.washington-backup = {
      description = "Incrementally mirror Washington and snapshot into local Restic";
      # Reload completion hooks without aborting a multi-day transfer on deploy.
      restartIfChanged = false;
      stopIfChanged = false;
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      onSuccess = [ "washington-backup-notify@backup.service" ];
      onFailure = [ "washington-backup-notify@backup.service" ];
      unitConfig.RequiresMountsFor = [ "/vault" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pull}/bin/washington-backup-pull";
        UMask = "0077";
        # Initial Immich exports can span several days; systemd does not
        # launch overlapping runs when a daily timer fires during a backup.
        TimeoutStartSec = "7d";
      };
      preStart = "${pkgs.coreutils}/bin/install -d -m 0700 ${repository} ${mirror}";
    };
    systemd.timers.washington-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = config.host.backup.washington.calendar;
        Persistent = true;
        RandomizedDelaySec = "10m";
      };
    };
    systemd.services.washington-backup-maintenance = {
      description = "Prune and check Washington Restic repository";
      onSuccess = [ "washington-backup-notify@backup-maintenance.service" ];
      onFailure = [ "washington-backup-notify@backup-maintenance.service" ];
      unitConfig.RequiresMountsFor = [ "/vault" ];
      path = [
        pkgs.restic
        pkgs.util-linux
      ];
      environment = {
        RESTIC_REPOSITORY = repository;
        RESTIC_PASSWORD_FILE = config.age.secrets.washington-restic-password.path;
      };
      serviceConfig = {
        Type = "oneshot";
        UMask = "0077";
        TimeoutStartSec = "7d";
      };
      script = ''
        exec 9>${state}/operation.lock
        flock 9
        test -f "$RESTIC_REPOSITORY/config" || exit 0
        # Group only by host so legacy tar and new file snapshots share retention.
        restic forget --host washington --group-by host --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --keep-yearly 1 --prune
        restic check
      '';
    };
    systemd.timers.washington-backup-maintenance = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Sun *-*-* 12:00:00";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
    systemd.services."washington-backup-notify@" = {
      description = "Send Gotify result for Washington %i on ${config.networking.hostName}";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${notify}/bin/washington-backup-notify %i";
        UMask = "0077";
      };
    };
  };
}
