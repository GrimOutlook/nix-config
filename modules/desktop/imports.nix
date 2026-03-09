{ config, ... }:
{
  flake.modules = {
    nixos.desktop.imports = with config.flake.modules.nixos; [
      display-manager
      sound
    ];
    homeManager.desktop.imports = with config.flake.modules.homeManager; [
      desktop-programs
      dunst
      rofi
      udiskie
      wayland
      zathura
    ];
  };
}
