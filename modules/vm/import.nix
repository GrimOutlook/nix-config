{ config, inputs, ... }:
{
  flake.modules.nixos.vm =
    { pkgs, ... }:
    {

      imports =
        with config.flake.modules.nixos;
        [

        ]
        // [
          inputs.microvm.nixosModules.microvm
        ];

      environment.systemPackages = with pkgs; [
      ];
    };
}
