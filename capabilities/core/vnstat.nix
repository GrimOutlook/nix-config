{
  config,
  lib,
  ...
}:
let
  cfg = config.host.vnstat;
in
{
  options.host.vnstat.enable = lib.mkEnableOption "Enable vnstat configurations";
  config = lib.mkIf cfg.enable {
    services.vnstat.enable = true;
  };
}
