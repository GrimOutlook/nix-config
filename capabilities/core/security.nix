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
  config = lib.mkIf cfg.enable {
    security.sudo-rs = {
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

    # Allow the owner to shut down and reboot the system without a polkit
    # prompt, even without an active local session (e.g. over SSH).
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          (action.id == "org.freedesktop.login1.power-off" ||
           action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
           action.id == "org.freedesktop.login1.reboot" ||
           action.id == "org.freedesktop.login1.reboot-multiple-sessions") &&
          subject.user == "${config.host.owner.username}"
        ) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
