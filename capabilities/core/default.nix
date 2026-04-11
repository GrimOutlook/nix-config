{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.host.core;
in
{
  options.host.core = {
    enable = lib.mkEnableOption "Enable core configurations" // {
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    imports = [
      inputs.disko.nixosModules.disko
    ];
    host = {
      agenix.enable = mkDefault true;
      custom-scripts.enable = mkDefault true;
      default-programs.enable = mkDefault true;
      home-manager.enable = mkDefault true;
      localizations.enable = mkDefault true;
      networking.enable = mkDefault true;
      nh.enable = mkDefault true;
      nix-index-database.enable = mkDefault true;
      nix.enable = mkDefault true;
      security.enable = mkDefault true;
      ssh-server.enable = mkDefault true;
      users.enable = mkDefault true;
      xdg.enable = mkDefault true;
    };
  };
}
