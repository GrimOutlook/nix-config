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

  config = lib.mkIf cfg.enable {
    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    nix.settings = {
      substituters = [ "https://raspberry-pi-nix.cachix.org" ];
      trusted-public-keys = [
        # Verified against https://raspberry-pi-nix.cachix.org/api/v1/cache/raspberry-pi-nix.
        # The previous value here decoded to 31 bytes rather than the 32 an
        # ed25519 key needs, so nix rejected the whole substituter list with
        # "error: public key is not valid" -- which failed every build on a
        # raspberry-pi host, not just fetches from this cache.
        "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
      ];
    };
  };
}
