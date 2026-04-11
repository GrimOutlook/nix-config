{
  config,
  inputs,
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
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];

    # runs programs without installing them
    programs = {
      nix-index-database.comma.enable = true;
    };
  };
}
