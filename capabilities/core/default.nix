{
  config,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.host.core;
in
{
  imports = [
    inputs.nix-config.inputs.disko.nixosModules.disko
  ];
  options.host.core = {
    enable = mkEnableOption "Enable core configurations" // {
      default = true;
    };
  };

  config =
    let
      enableAll =
        modules: map (module: setAttrByPath [ "host" "${module}" ] { enable = mkDefault true; }) modules;
    in
    mkIf cfg.enable (
      lib.mkMerge (enableAll [
        "agenix"
        "custom-scripts"
        "default-programs"
        "home-manager"
        "localization"
        "networking"
        "nix-index-database"
        "nix"
        "security"
        "ssh-server"
        "troubleshooting"
        "users"
        "xdg"
      ])
    );
}
