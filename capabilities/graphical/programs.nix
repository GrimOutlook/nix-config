{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.graphical-programs;
in
{
  options.host.graphical-programs.enable = lib.mkEnableOption "Enable graphical applications";

  config = lib.mkIf cfg.enable {
    host.home-manager.home.packages = with pkgs; [
      # Terminal
      alacritty

      # File Manager
      xfce.thunar

      # IM
      discord

      # Browser
      # TODO: Add `zen-browser` to `nixpkgs`
      # zen-browser
      firefox

      # Video
      mpv
      vlc

      # Misc
      #spotify
    ];
  };
}
