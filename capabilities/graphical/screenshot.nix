{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.screenshot;
in
{
  options.host.screenshot.enable = lib.mkEnableOption "Enable screenshot tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gpu-screen-recorder-gtk
    ];
    programs.gpu-screen-recorder.enable = true;

    host.home-manager = {
      home.packages = with pkgs; [
        grim
      ];
      services.flameshot = {
        enable = true;
        settings = {
          General = {

            # More settings may be found on the Flameshot Github

            # Save Path
            savePath = "/home/${config.host.owner.username}/Pictures/Screenshots";
            # Tray
            disabledTrayIcon = true;
            # Greeting message
            showStartupLaunchMessage = false;
            # Default file extension for screenshots (.png by default)
            saveAsFileExtension = ".png";
            # Desktop notifications
            showDesktopNotification = true;
            # Notification for cancelled screenshot
            showAbortNotification = false;
            # Whether to show the info panel in the center in GUI mode
            showHelp = true;
            # Whether to show the left side button in GUI mode
            showSidePanelButton = true;

            # Color Customization
            uiColor = "#740096";
            contrastUiColor = "#270032";
            drawColor = "#ff0000";

            # For Wayland (Install Grim seperately)
            useGrimAdapter = true;
            # Stops warnings for using Grim
            disabledGrimWarning = true;
          };
        };
      };
      wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
        # Takes a manual screenshot that shows options after selection.
        "$mainMod, PRINT, exec, flameshot gui"
        # Manual screenshot GUI that saves to clipboard and closes on selection.
        "PRINT, exec, flameshot gui --clipboard --accept-on-select"
      ];
    };
  };
}
