{
  config,
  lib,
  ...
}:
let
  cfg = config.host.graphical;
in
{
  options.host.graphical.enable = lib.mkEnableOption "Enable graphical configurations";

  config =
    let
      enableAll =
        modules:
        map (module: lib.setAttrByPath [ "host" "${module}" ] { enable = lib.mkDefault true; }) modules;
    in
    lib.mkIf cfg.enable (
      lib.mkMerge (enableAll [
        "boot-screen"
        "display-manager"
        "graphical-programs"
        "hyprland"
        "hyprpanel"
        "nerd-fonts"
        "rofi"
        "screenshot"
        "sound"
        "stylix"
        "udiskie"
        "wayland"
        "zathura"
      ])
    );
}
