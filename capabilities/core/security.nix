{
  config,
  lib,
  ...
}:
let
  cfg = config.host.security;
in
{
  options.host.security = {
    enable = lib.mkEnableOption "Enable default security configurations";
  };
  config.security.sudo-rs = lib.mkIf cfg.enable {
    enable = true;
    extraRules = [
      # Allow execution of any command by all users in group sudo,
      # requiring a password.
      {
        groups = [ "sudo" ];
        commands = [ "ALL" ];
      }
    ];
  };
}
