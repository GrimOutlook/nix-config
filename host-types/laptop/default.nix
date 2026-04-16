{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.type.laptop;
in
{
  options.host.type.laptop.enable = lib.mkEnableOption "Enable laptop configurations";

  config = lib.mkIf cfg.enable {
    host = {
      antivirus.enable = true;
      bluetooth.enable = true;
      bootloader.enable = true;
      graphical.enable = true;
    };

    programs.light = {
      enable = true;
      brightnessKeys.enable = true;
    };

    environment.systemPackages = with pkgs; [
      acpi
      upower
    ];
    services.acpid.enable = true;
    services.upower.enable = true;
  };
}
