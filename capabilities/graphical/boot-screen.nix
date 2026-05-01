{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.boot-screen;
  inherit (lib) mkDefault;
in
{
  options.host.boot-screen.enable = lib.mkEnableOption "Enable boot screen (plymouth)";

  config.boot = lib.mkIf cfg.enable {
    plymouth = {
      enable = true;
      theme = "cuts";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "cuts" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd = {
      # WARN: Very experimental at the moment but makes plymouth start much earlier.
      systemd.enable = mkDefault true;
      verbose = mkDefault false;
    };
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "udev.log_level=3"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };
}
