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
    # Terminal. Enabled through home-manager (rather than just installing the package) so that
    # stylix themes it; otherwise alacritty keeps its built-in background and clashes with
    # tmux/nixvim.
    host.home-manager.config.programs.alacritty.enable = true;

    host.home-manager.config.home.packages = with pkgs; [
      # File Manager
      thunar

      # IM
      discord

      # Video
      mpv
      vlc

      # Misc
      #spotify

      # Small Gotify daemon to send messages as desktop notifications
      # https://github.com/desbma/gotify-desktop
      gotify-desktop

      # Calculator
      qalculate-qt
    ];
  };
}
