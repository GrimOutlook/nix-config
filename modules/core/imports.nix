{ config, inputs, ... }:
{
  flake.modules = {

    # TODO: Deduplicate these imports
    nixos.core.imports = with config.flake.modules.nixos; [
      inputs.disko.nixosModules.disko

      agenix
      homeManager
      security
      ssh-server
      users
    ];

    homeManager.core.imports = with config.flake.modules.homeManager; [
      agenix
      nix-index-database
      xdg
    ];
  };
}
