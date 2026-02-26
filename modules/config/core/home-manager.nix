topLevel@{ config, inputs, ... }:
let
  username = config.meta.owner.username;
in
{
  flake.modules = {
    nixos.homeManager =
      { config, ... }:
      let
        inherit (config.networking) hostName;
      in
      {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;

          users.${username}.imports = [
            topLevel.config.flake.modules.homeManager.core
            (topLevel.config.flake.modules.homeManager."host_${hostName}" or { })
          ];

          extraSpecialArgs = {
            inputs = inputs;
            configName = "nixos_${hostName}";
            nhSwitchCommand = "nh os switch";
            nhFlake = topLevel.config.host-info.flake;
          };
        };
      };

    homeManager.core =
      { lib, pkgs, ... }:
      {
        home = {
          username = "${username}";
          homeDirectory = lib.mkForce "/${if pkgs.stdenv.isLinux then "home" else "Users"}/${username}";
          stateVersion = "25.11";
        };
        programs.home-manager.enable = true;
      };
  };
}
