{
  flake.modules.homeManager.graphical =
    { pkgs, lib, ... }:
    {
      programs.hyprpanel = {
        enable = true;
        systemd.enable = true;
        # To edit, copy the Nix file to `~/.config/hyprpanel/config.json`, make
        # changes, then copy the file over `config.json` in this directory.
        # Rebuilding will reflect the changes you made.
        settings = builtins.fromJSON (builtins.readFile ./config.json);
      };
    };
}
