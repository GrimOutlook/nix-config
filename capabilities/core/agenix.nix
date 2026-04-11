{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.disable_ipv6;
in
{
  options.host.disable_ipv6 = {
    enable = lib.mkEnableOption "Enable agenix configurations";
  };
  config = lib.mkIf cfg.enable {
    imports = [
      inputs.agenix.nixosModules.default
    ];

    environment.systemPackages = with pkgs; [
      rage
      ragenix
    ];
  };
}
