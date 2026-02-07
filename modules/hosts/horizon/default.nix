{ config, ... }:
{
  nixosHosts.horizon = {
    unstable = true;
  };

  flake.modules.nixos.host_horizon.imports = with config.flake.modules.nixos; [
    desktop
    dev
    wsl
  ];
}
