{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.host.networking;
in
{
  options.host.networking = {
    enable = mkEnableOption "Enable networking configurations";
  };
  config = mkIf cfg.enable {
    networking = {
      networkmanager.enable = mkDefault true;
      nftables.enable = mkDefault true;
      firewall = {
        enable = mkDefault true;
        logRefusedConnections = mkDefault true;
      };
    };

    environment.shellAliases = {
      "clear-dns" = "sudo nscd -i hosts";
    };
  };
}
