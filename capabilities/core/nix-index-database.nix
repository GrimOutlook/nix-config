{
  config,
  lib,
  ...
}:
let
  cfg = config.host.nix-index-database;
in
{
  options.host.nix-index-database = {
    enable = lib.mkEnableOption "Enable nix-index-database configurations";
  };

  config = lib.mkIf cfg.enable {
    # runs programs without installing them
    programs = {
      nix-index-database.comma.enable = true;
    };
  };
}
