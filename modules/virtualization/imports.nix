{ inputs, ... }:
{
  flake.modules.nixos.virtualization =
    { lib, pkgs, ... }:
    {
      imports = [
        inputs.microvm.nixosModules.host
      ];

      environment.systemPackages = with pkgs; [
        podman
      ];

      # A Rust based QEMU alternative.
      microvm.hypervisor = lib.mkDefault "cloud-hypervisor";
    };
}
