{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.antivirus;
in
{
  options.host.antivirus.enable = lib.mkEnableOption "Enable antivirus configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      clamav
    ];
    services.clamav = {
      daemon = {
        enable = true;
        settings = {
          OnAccessIncludePath = [ "/home" ];
          OnAccessPrevention = true;
          OnAccessExcludeUname = "clamav";
        };
      };
      scanner.enable = true;
      updater.enable = true;
    };
  };
}
