{
  config,
  lib,
  ...
}:
let
  cfg = config.host.default-program.ssh;
in
{
  options.host.default-program.ssh.enable = lib.mkEnableOption "Enable default ssh configurations";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings."*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
}
