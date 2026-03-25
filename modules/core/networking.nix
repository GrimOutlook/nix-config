{ lib, ... }:
with lib;
{
  flake.modules.nixos.core = {
    networking = {
      networkmanager.enable = mkDefault true;
      nftables.enable = mkDefault true;
      firewall = {
        enable = mkDefault true;
        logRefusedConnections = mkDefault true;
      };
    };
  };
}
