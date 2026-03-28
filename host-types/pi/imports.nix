{ config, inputs, ... }:
{
  flake.modules = {
    nixos.pi =
      { lib, pkgs, ... }:
      {
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ];
        nixpkgs.buildPlatform = "x86_64-linux";
        nixpkgs.hostPlatform = "aarch64-linux";
      };
    home.pi.imports = with config.flake.modules.home; [
    ];
  };
}
