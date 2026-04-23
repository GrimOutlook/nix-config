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
    host.home-manager.config.home.packages = with pkgs; [
      # Terminal
      alacritty

      # File Manager
      xfce.thunar

      # IM
      discord

      # Browser
      firefox

      # Video
      mpv
      vlc

      # Misc
      #spotify

      # Small Gotify daemon to send messages as desktop notifications
      # https://github.com/desbma/gotify-desktop
      gotify-desktop
    ];
  };
}
