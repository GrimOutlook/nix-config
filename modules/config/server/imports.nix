{ config, ... }:
{
  flake.modules.nixos.server = 
    {pkgs, ...}:
    {
      imports = with config.flake.modules.nixos; [
        bootloader
      ];

      environment.systemPackages = with pkgs; [
        podman
      ];
    };
}
