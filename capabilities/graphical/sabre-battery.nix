{ config, lib, pkgs, ... }:
let
  cfg = config.host.sabre-battery;
  battery = pkgs.writeShellApplication {
    name = "sabre-battery";
    text = ''
      exec ${pkgs.python3}/bin/python3 ${./_sabre-battery/sabre_battery.py} "$@"
    '';
  };
in
{
  options.host.sabre-battery.enable = lib.mkEnableOption "Corsair Sabre v2 Pro battery reader";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ battery ];
    # Only the local active session gets access, not all users or all HID devices.
    # Must precede systemd's 73-seat-late.rules, which applies uaccess ACLs.
    services.udev.packages = [
      (pkgs.writeTextDir "lib/udev/rules.d/70-sabre-battery.rules" ''
        ACTION!="remove", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="2b2a", TAG+="uaccess"
      '')
    ];
  };
}
