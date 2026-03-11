{ config, ... }:
{
  flake.modules = {
    nixos.laptop.imports = with config.flake.modules.nixos; [
      graphical
      physical
    ];
    homeManager.laptop.imports = with config.flake.modules.homeManager; [
      graphical
    ];
  };
}
