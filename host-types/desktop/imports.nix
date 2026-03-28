{ config, ... }:
{
  flake.modules = {
    nixos.desktop.imports = with config.flake.modules.nixos; [
      antivirus
      bluetooth
      bootloader
      graphical
    ];
    homeManager.desktop.imports = with config.flake.modules.homeManager; [
      graphical
    ];
  };
}
