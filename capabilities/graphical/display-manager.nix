{
  config,
  lib,
  ...
}:
let
  cfg = config.host.display-manager;
in
{
  options.host.display-manager.enable = lib.mkEnableOption "Enable display manager (regreet)";

  config = lib.mkIf cfg.enable {
    programs.regreet = {
      enable = true;
      settings = {
        GTK = {
          application_prefer_dark_theme = true;
        };
      };
    };
  };
}
