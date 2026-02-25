{
  lib,
  ...
}:
let
  hostInfoModule = { lib, ... }: {
    options.host-info = lib.mkOption {
      type = lib.types.submodule {
        options.flake = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Path to the host's flake directory for nh";
        };
        options.name = lib.mkOption {
          type = lib.types.str;
          description = "Configuration name (used as hostname for NixOS and config name for home-manager)";
        };
      };
      default = { };
      description = "Host-specific information for nix-config modules";
    };
  };
in
{
  imports = [ hostInfoModule ];
  config.flake.modules.flake.host-info = hostInfoModule;
}
