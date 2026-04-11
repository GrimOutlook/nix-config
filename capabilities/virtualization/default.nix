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
    ];
  };
}
