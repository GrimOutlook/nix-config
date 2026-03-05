{ lib, ... }:
{
  flake.modules.nixos.core = {
    networking = {
      networkmanager.enable = true;
      nftables.enable = lib.mkDefault true;
      firewall = {
        enable = true;
        logRefusedConnections = true;
      };
    };
  };
}
