{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.lang.database;
in
{
  options.host.lang.database.enable =
    lib.mkEnableOption "Enable database access and language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config = {
      home.packages = with pkgs; [
        # Database management TUI for Postgres, MySQL, and SQLite
        # https://github.com/achristmascarl/rainfrog
        rainfrog
      ];
    };
  };
}
