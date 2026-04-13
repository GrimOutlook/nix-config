{
  config,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.host.home-manager;
in
{

  imports = [
    inputs.nix-config.inputs.home-manager.nixosModules.default
  ];

  options.host.home-manager = {
    enable = mkEnableOption "Enable home-manager configurations";

    config = mkOption {
      type = types.deferredModule;
      default = { };
      description = "home-manager configurations that are passed to the `home-manager.users.\${owner}` field";
    };
  };

  config.home-manager =
    let
      inherit (config.host.owner) username;
    in
    mkIf cfg.enable {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${username} = {
        home.homeDirectory = "/home/${username}";

        imports = [ cfg.config ];
      };
    };
}
