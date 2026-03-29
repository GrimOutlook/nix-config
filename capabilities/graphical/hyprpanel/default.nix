{
  flake.modules.homeManager.graphical =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    with lib;
    let
      # To edit, copy the Nix file to `~/.config/hyprpanel/config.json`, make
      # changes, then copy the file over `config.json` in this directory.
      # Rebuilding will reflect the changes you made.
      baseConfig = builtins.fromJSON (builtins.readFile ./config.json);
    in
    {
      options.host.hyprpanel.extraSettings = mkOption {
        type = types.attrs;
        default = { };
        description = "Settings to merge on top of the base hyprpanel config";
      };
      config.programs.hyprpanel = {

        enable = true;
        systemd.enable = true;
        settings = lib.recursiveUpdate baseConfig config.host.hyprpanel.extraSettings;
      };
    };
}
