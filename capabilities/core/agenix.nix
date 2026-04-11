{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.agenix;
in
{
  imports = [
    inputs.nix-config.inputs.agenix.nixosModules.default
  ];
  options.host.agenix = {
    enable = lib.mkEnableOption "Enable agenix configurations";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rage
      ragenix
    ];
  };
}
