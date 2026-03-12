topLevel@{ config, inputs, ... }:
let
  username = config.meta.owner.username;
in
{
  flake.modules = {
    nixos.homeManager =
      { config, lib, ... }:
      let
        inherit (config.networking) hostName;
      in
      {
        options.home-manager.extraModules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [ ];
          description = "Additional home-manager modules to import";
        };

        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];

        config.home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;

          users.${username}.imports = [
            topLevel.config.flake.modules.homeManager.core
          ]
          ++ config.home-manager.extraModules;

          extraSpecialArgs = {
            inputs = inputs;
            configName = topLevel.config.host-info.name;
            nhFlake = topLevel.config.host-info.flake;
          };
        };
      };

    homeManager.core =
      { lib, pkgs, ... }:
      {
        home = {
          username = username;
          homeDirectory = lib.mkForce "/${if pkgs.stdenv.isLinux then "home" else "Users"}/${username}";
          stateVersion = "25.11";
        };
        # Enable bash in home-manager so bash completions work
        programs.bash.enable = true;
      };
  };
}
