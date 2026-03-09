{ config, ... }:
{
  flake.modules.nixos.physical.imports = with config.flake.modules.nixos; [
    bootloader
  ];
}
