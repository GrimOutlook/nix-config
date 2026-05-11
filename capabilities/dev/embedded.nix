{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.embedded;
in
{
  options.host.dev.embedded.enable = lib.mkEnableOption "Enable embedded development configurations";

  config = lib.mkIf cfg.enable {
    services.udev = {
      packages = [ pkgs.probe-rs-tools ];

      extraRules = ''
        # Allow Seeed XIAO nRF52480
        ATTRS{idVendor}=="2886", ENV{ID_MM_DEVICE_IGNORE}="1"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="2886", MODE="0666"
        SUBSYSTEM=="tty", ATTRS{idVendor}=="2886", MODE="0666"
      '';
    };
    users = {
      groups.plugdev = { };
      users.${config.host.owner.username}.extraGroups = [
        "plugdev"
        "dialout"
      ];
    };
  };
}
