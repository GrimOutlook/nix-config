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

  config = {
    # The imported module turns `programs.nix-index` on by default the moment
    # it is in the module list, so this capability has to drive that option
    # explicitly -- otherwise a host that opts out still pays for the prebuilt
    # index database, which is by far the biggest thing here.
    programs.nix-index.enable = cfg.enable;

    # runs programs without installing them
    programs.nix-index-database.comma.enable = lib.mkIf cfg.enable true;
  };
}
