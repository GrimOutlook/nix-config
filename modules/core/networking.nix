{ lib, ... }:
{
  flake.modules.nixos.core = {
    networking = {
      networkmanager.enable = lib.mkDefault true;
      nftables.enable = lib.mkDefault true;
      firewall = {
        enable = lib.mkDefault true;
        logRefusedConnections = lib.mkDefault true;
      };
    };
  };
}
