{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.bluetooth;
in
{
  options.host.bluetooth.enable = lib.mkEnableOption "Enable bluetooth configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bluetui
      bluez
    ];
    hardware.bluetooth.enable = true;
  };
}
