{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.host.virtualization;
in
{
  imports = [
    inputs.nix-config.inputs.microvm.nixosModules.host
  ];

  options.host.virtualization.enable = lib.mkEnableOption "Enable virtualization configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      podman

      # Top-like interface for container metrics
      # https://github.com/bcicen/ctop
      ctop

      # Tool for exploring each layer in a Docker image
      # https://github.com/wagoodman/dive
      dive
    ];

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
  };
}
