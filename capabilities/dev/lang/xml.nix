{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.lang.xml;
in
{
  options.host.lang.xml.enable = lib.mkEnableOption "Enable XML language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.home.packages = with pkgs; [
      libxml2
    ];
  };
}
