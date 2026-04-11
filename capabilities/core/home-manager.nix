{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.host.home-manager;
in
{
  options.host.home-manager = mkOption {
    type = types.submodule {
      freeformType = types.attrsOf types.anything;
      options = {
        enable = mkOption {
          type = types.bool;
          default = mkDefault true;
        };
      };
    };

    description = "home-manager configurations that are passed to the `home-manager.users.\${owner}` field";
  };

  config = mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${config.host.owner.username} = removeAttrs cfg [ "enable" ];
    };
  };
}
