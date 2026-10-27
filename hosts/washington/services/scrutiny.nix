{
  homelab,
  host_info,
  pkgs,
  ...
}:
let
  port = host_info.services.scrutiny.ports.web;
in
{
  services.scrutiny = {
    enable = true;
    settings.web.listen = {
      port = port.number;
      host = "0.0.0.0";
    };
  };

  networking.firewall.extraInputRules = homelab.lib.firewallAllowLocal port.number;
}
