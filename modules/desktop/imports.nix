{ config, ... }:
{
  flake.modules = {
    nixos.desktop.imports = with config.flake.modules.nixos; [
      graphical
      physical
    ];
    homeManager.desktop.imports = with config.flake.modules.homeManager; [
      graphical
    ];
  };
}
