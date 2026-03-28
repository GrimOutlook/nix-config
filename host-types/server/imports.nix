{ config, ... }:
{
  flake.modules.nixos.server =
    { lib, pkgs, ... }:
    {
      imports = with config.flake.modules.nixos; [
        antivirus
        bootloader
        virtualization
      ];
    };
}
