{ config, inputs, ... }:
{
  flake.modules.nixos.laptop =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        acpi
      ];
      services.acpid.enable = true;


    };
}
