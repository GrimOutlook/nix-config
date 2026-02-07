{ config, inputs, ... }:
{
  flake.modules.nixos.core.imports = with config.flake.modules.nixos; [
    agenix
    nix
    security
    ssh-server
    users
  ];
}
