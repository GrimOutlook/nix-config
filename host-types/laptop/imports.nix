{ config, ... }:
{
  flake.modules = {
    nixos.laptop.imports = with config.flake.modules.nixos; [
      antivirus
      bluetooth
      bootloader
      graphical
    ];
    homeManager.laptop.imports = with config.flake.modules.homeManager; [
      graphical
    ];
  };
}
