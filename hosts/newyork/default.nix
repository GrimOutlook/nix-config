{
  imports = [
    ./networking/dhcp.nix
    ./networking/router.nix
    ./services/gotify.nix
    ./services/fail2ban-ui.nix
    ./services/crowdsec-web-ui.nix
    ./services/evebox.nix
    ./services/suricata.nix
    ./services/vaultwarden-notify.nix
    ./services/paperless-notify.nix
  ];
}
