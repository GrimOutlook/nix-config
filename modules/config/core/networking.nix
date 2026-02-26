{
  flake.modules.nixos.core = {
    networking = {
      networkmanager.enable = true;
      firewall.enable = true;
    };
  };
}
