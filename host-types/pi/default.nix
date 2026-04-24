{
  config,
  lib,
  ...
}:
let
  cfg = config.host.type.raspberry-pi;
in
{
  options.host.type.raspberry-pi.enable = lib.mkEnableOption "Enable raspberry-pi configurations";

  # config = lib.mkIf cfg.enable {
  #   nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  #   nix.settings = {
  #     substituters = [ "https://raspberry-pi-nix.cachix.org" ];
  #     trusted-public-keys = [
  #       "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0KTFjanUjs096+7CwhvL32Ggca9M4w="
  #     ];
  #   };
  # };
}
