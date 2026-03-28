{ config, inputs, ... }:
{
  flake.modules.nixos.vm =
    { lib, pkgs, ... }:
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

      # A Rust based QEMU alternative.
      microvm.hypervisor = lib.mkDefault "cloud-hypervisor";
    };
}
