{ config, lib, ... }:
let
  cfg = config.host.type.desktop;
in
{
  options.host.type.desktop.enable = lib.mkEnableOption "Enable desktop configurations";

  config = lib.mkIf cfg.enable {
    host = {
      antivirus.enable = true;
      bluetooth.enable = true;
      bootloader.enable = true;
      # graphical.enable = true;
    };
  };
}
