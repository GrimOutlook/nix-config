{
  config,
  lib,
  nix-config-inputs,
  pkgs,
  ...
}:
let
  cfg = config.host.virtualization;
in
{
  options.host.virtualization.enable = lib.mkEnableOption "Enable virtualization configurations";

  config = lib.mkIf cfg.enable {
    imports = [
      nix-config-inputs.microvm.nixosModules.host
    ];

    environment.systemPackages = with pkgs; [
      podman
    ];
  };
}
