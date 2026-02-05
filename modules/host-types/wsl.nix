{ config, inputs, ... }:
{
  flake.modules.nixos.wsl = {
    imports = with config.flake.modules.nixos; [ 
      base
      inputs.nixos-wsl.nixosModules.default
    ];

    wsl.enable = true;
  };
}
