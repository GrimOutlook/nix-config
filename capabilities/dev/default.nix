{ config, ... }:
{
  flake.modules = {
    nixos.dev = {
      # Enable nix-ld for easier uv use
      programs.nix-ld.enable = true;
    };
    homeManager.dev.imports = with config.flake.modules.homeManager; [
      git
      nixvim
    ];
  };
}
