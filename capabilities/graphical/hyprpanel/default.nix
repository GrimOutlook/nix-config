{
  config,
  lib,
  ...
}:
let
  cfg = config.host.hyprpanel;
  # To edit, copy the Nix file to `~/.config/hyprpanel/config.json`, make
  # changes, then copy the file over `config.json` in this directory.
  # Rebuilding will reflect the changes you made.
  baseConfig = builtins.fromJSON (builtins.readFile ./config.json);
in
{
  options.host.hyprpanel = {
    enable = lib.mkEnableOption "Enable hyprpanel";
    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Settings to merge on top of the base hyprpanel config";
    };
  };

  config = lib.mkIf cfg.enable {
    host.home-manager.programs.hyprpanel = {
      enable = true;
      systemd.enable = true;
      settings = lib.recursiveUpdate baseConfig cfg.extraSettings;
    };
  };
}
