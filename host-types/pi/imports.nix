{ config, inputs, ... }:
{
  flake.modules = {
    nixos.pi =
      { lib, pkgs, ... }:
      with lib;
      {
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ];
        nixpkgs.hostPlatform = mkDefault "aarch64-linux";
        nix.settings = {
          substituters = [ "https://raspberry-pi-nix.cachix.org" ];
          trusted-public-keys = [
            "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0KTFjanUjs096+7CwhvL32Ggca9M4w="
          ];
        };
        system.autoUpgrade.enable = mkDefault true;
      };
    home.pi.imports = with config.flake.modules.home; [
    ];
  };
}
