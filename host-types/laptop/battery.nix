{
  flake.modules.nixos.laptop =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        acpi
        upower
      ];
      services.acpid.enable = true;
      services.upower.enable = true;

    };
}
