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

    # Allow the owner to connect to wifi networks and change network
    # settings (via nmcli/nmtui/nm-applet) without a polkit prompt on
    # desktop systems.
    users.users.${config.host.owner.username}.extraGroups = lib.optionals config.host.graphical.enable [
      "networkmanager"
    ];

    environment.shellAliases = {
      "clear-dns" = "sudo nscd -i hosts";
    };
  };
}
