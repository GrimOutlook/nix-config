{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.lang.xml;
in
{
  options.host.dev.lang.xml.enable = lib.mkEnableOption "Enable XML language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.home.packages = with pkgs; [
      libxml2
    ];
  };
}
