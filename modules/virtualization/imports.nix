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
    };
}
