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

      # Top-like interface for container metrics
      # https://github.com/bcicen/ctop
      ctop

      # Tool for exploring each layer in a Docker image
      # https://github.com/wagoodman/dive
      dive

      # A tool for managing OCI containers and pods.
      # https://github.com/containers/podman
      podman
    ];

    virtualisation = {
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        defaultNetwork.settings = {
          default-address-pools = [
            {
              base = "172.27.0.0/16";
              size = 24;
            }
          ];
          # Required for containers under podman-compose to be able to talk to each other.
          dns_enabled = true;
        };
        dockerCompat = true;
        # dockerSocket.enable = true;
      };
    };
  };
}
