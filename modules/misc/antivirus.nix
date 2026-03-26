{
  flake.modules.nixos.antivirus =
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
    };
}
