{ config, lib, ... }:
let
  cfg = config.host.type.server;
in
{
  options.host.type.server = {
    enable = lib.mkEnableOption "Enable server configurations";
  };
  config = lib.mkIf cfg.enable {
    host = {
      antivirus.enable = true;
      bootloader.enable = true;
      virtualization.enable = true;
    };
  };
}
