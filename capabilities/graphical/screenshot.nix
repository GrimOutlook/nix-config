{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.screenshot;
  # Relative to the owner's home directory.
  screenshotDir = "Pictures/Screenshots";
  savePath = "/home/${config.host.owner.username}/${screenshotDir}";

  # Flameshot used to provide both of these. It cannot work on a scaled
  # display: its grim adapter blits grim's native-pixel capture 1:1 into a Qt
  # window sized in logical points, so on a scale-2 monitor the overlay shows
  # the top-left quadrant at 2x. No env var fixes it, its portal path is
  # broken, and XWayland only moves the breakage around -- so capture and
  # annotation are split across grim/slurp/satty, which handle scaling.

  # slurp exits non-zero when the selection is cancelled; don't capture then.
  selectRegion = ''region=$(slurp -d) || exit 0'';

  # Select a region, then annotate it before saving/copying.
  screenshot-annotate = pkgs.writeShellApplication {
    name = "screenshot-annotate";
    runtimeInputs = with pkgs; [
      grim
      slurp
      satty
      wl-clipboard
    ];
    text = ''
      ${selectRegion}
      grim -g "$region" - | satty --filename - \
        --output-filename "${savePath}/%Y-%m-%d_%H-%M-%S.png" \
        --copy-command wl-copy \
        --early-exit
    '';
  };

  # Select a region and put it straight on the clipboard.
  screenshot-clipboard = pkgs.writeShellApplication {
    name = "screenshot-clipboard";
    runtimeInputs = with pkgs; [
      grim
      slurp
      wl-clipboard
    ];
    text = ''
      ${selectRegion}
      grim -g "$region" - | wl-copy
    '';
  };
in
{
  options.host.screenshot.enable = lib.mkEnableOption "Enable screenshot tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gpu-screen-recorder-gtk
    ];
    programs.gpu-screen-recorder.enable = true;

    host.home-manager.config = {
      home.packages = with pkgs; [
        grim
        slurp
        satty
        screenshot-annotate
        screenshot-clipboard
      ];
      # satty writes into this directory, so it has to already exist.
      home.file."${screenshotDir}/.keep".text = "";

      # satty is a transient annotation window; keep it out of the tiling layout.
      wayland.windowManager.hyprland.settings.windowrule = lib.mkAfter [
        ''float 1, match:class ^com\.gabm\.satty$''
      ];

      wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
        # Takes a manual screenshot that shows options after selection.
        "$mainMod, PRINT, exec, ${lib.getExe screenshot-annotate}"
        # Manual screenshot that saves to clipboard and closes on selection.
        ", PRINT, exec, ${lib.getExe screenshot-clipboard}"
      ];
    };
  };
}
