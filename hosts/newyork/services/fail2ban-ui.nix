{
  config,
  host_info,
  pkgs,
  ...
}:
let
  port =
    if host_info.services ? fail2ban-ui then
      host_info.services.fail2ban-ui.ports.web.number
    else if host_info.services ? fail2ban_ui then
      host_info.services.fail2ban_ui.ports.web.number
    else if host_info.services ? fail2banui then
      host_info.services.fail2banui.ports.web.number
    else
      50007;
in
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.fail2ban-ui = {
      image = "swissmakers/fail2ban-ui:latest";
      ports = [ "127.0.0.1:${toString port}:8080" ];
      environment = {
        PORT = "8080";
      };
      volumes = [
        "/var/lib/fail2ban-ui:/config"
        "/etc/fail2ban:/etc/fail2ban:ro"
        "/var/log:/var/log:ro"
        "/var/run/fail2ban:/var/run/fail2ban"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/fail2ban-ui 0755 root root -"
  ];
}
