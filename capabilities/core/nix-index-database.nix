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
  imports = [
    inputs.nix-config.inputs.nix-index-database.nixosModules.nix-index
  ];

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
