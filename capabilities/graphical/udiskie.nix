{
  config,
  lib,
  ...
}:
let
  cfg = config.host.udiskie;
in
{
  options.host.udiskie.enable = lib.mkEnableOption "Enable udiskie automount service";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.services.udiskie = {
      enable = true;
      tray = "never";
    };
  };
}
