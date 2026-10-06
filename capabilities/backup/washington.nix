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
  pull = pkgs.writeShellApplication {
    name = "washington-backup-pull";
    runtimeInputs = [
      pkgs.openssh
      pkgs.restic
      pkgs.coreutils
    ];
    text = ''
      export RESTIC_REPOSITORY=${repository}
      export RESTIC_PASSWORD_FILE=${config.age.secrets.washington-restic-password.path}
      # A failed producer must never create a successful truncated snapshot.
      # Stage the stream first, then ingest it; delete staging on every exit.
      archive=$(mktemp ${repository}/.incoming.XXXXXX)
      trap 'rm -f "$archive"' EXIT
      ssh -T -i ${config.age.secrets.washington-backup-ssh-key.path} -o IdentitiesOnly=yes \
        -o BatchMode=yes -o StrictHostKeyChecking=yes \
        -o UserKnownHostsFile=${state}/known_hosts \
        -o ConnectTimeout=30 -o ServerAliveInterval=30 -o ServerAliveCountMax=3 \
        ${lib.escapeShellArg "backup-pull@${config.host.backup.washington.address}"} > "$archive"
      if [ ! -f "$RESTIC_REPOSITORY/config" ]; then
        restic init
      fi
      restic backup --host washington --stdin --stdin-filename washington.tar < "$archive"
      restic forget --host washington --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --keep-yearly 1 --prune
      restic check
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
      description = "Pull Washington export into encrypted local Restic repository";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      unitConfig.RequiresMountsFor = [ "/vault" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pull}/bin/washington-backup-pull";
        UMask = "0077";
        TimeoutStartSec = "12h";
      };
      preStart = "${pkgs.coreutils}/bin/install -d -m 0700 ${repository}";
    };
    systemd.timers.washington-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = config.host.backup.washington.calendar;
        Persistent = true;
        RandomizedDelaySec = "10m";
      };
    };
  };
}
