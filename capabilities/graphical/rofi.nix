{
  config,
  lib,
  ...
}:
let
  cfg = config.host.rofi;
in
{
  options.host.rofi.enable = lib.mkEnableOption "Enable rofi launcher";

  config = lib.mkIf cfg.enable {
    host.home-manager.programs.rofi = {
      enable = true;

      # font = "DejaVu Sans Mono 18";
      # theme = "gruvbox-dark";
    };
  };
}
