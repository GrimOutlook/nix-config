{
  config,
  lib,
  ...
}:
let
  cfg = config.host.deployment.client;
  owner = config.host.owner.username;
in
{
  options.host.deployment.client.enable = lib.mkEnableOption "Enable fleet deployment client support" // {
    default = true;
  };

  # Keep the option available everywhere, but only install the fleet key on
  # hosts explicitly marked as development systems.
  config = lib.mkIf (cfg.enable && config.host.dev.enable) {
    assertions = [
      {
        assertion = config.host.agenix.enable;
        message = "host.deployment.client requires host.agenix.enable";
      }
    ];

    # Keep the decrypted key in /run rather than the home directory. It is
    # owned by the interactive user and is added to ssh-agent on first use for
    # deployment connections.
    age.secrets.nix-deploy-key = {
      file = ../../secrets/deploy-key.age;
      owner = owner;
      group = owner;
      mode = "0400";
    };

    host.home-manager.config.programs.ssh.settings."Match user deploy" = {
      IdentityFile = "/run/agenix/nix-deploy-key";
      AddKeysToAgent = "yes";
    };
  };
}
