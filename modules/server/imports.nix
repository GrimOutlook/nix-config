{ config, inputs, ... }:
{
  flake.modules.nixos.server =
    { lib, pkgs, ... }:
    {
      imports =
        with config.flake.modules.nixos;
        [
          bootloader
        ]
        // [
          inputs.microvm.nixosModules.host
        ];

      environment.systemPackages = with pkgs; [
        podman
      ];

      # A Rust based QEMU alternative.
      microvm.hypervisor = lib.mkDefault "cloud-hypervisor";
    };
}
