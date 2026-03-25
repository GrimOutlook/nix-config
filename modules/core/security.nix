{
  flake.modules.nixos.security =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        clamav
      ];
      services.clamav = {
        daemon.enable = true;
        scanner.enable = true;
        updater.enable = true;
      };

      security = {
        sudo-rs = {
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
      };
    };
}
