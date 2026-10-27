{
  homelab,
  ...
}:
let
  inherit (homelab.hosts.newyork.services.gotify) ports;
in
{
  services.gotify = {
    enable = true;
    environment = {
      GOTIFY_SERVER_PORT = ports.web.number;
    };
  };
  networking.firewall.extraInputRules = homelab.lib.firewallAllowLocal ports.web.number;
}
