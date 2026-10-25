{
  config,
  host_info,
  pkgs,
  ...
}:
let
  port =
    if host_info.services ? evebox then
      host_info.services.evebox.ports.web.number
    else if host_info.services ? suricata then
      host_info.services.suricata.ports.web.number
    else
      50008;
in
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.evebox = {
      image = "jasonish/evebox:latest";
      cmd = [
        "evebox"
        "server"
        "--database"
        "sqlite"
        "--host"
        "0.0.0.0"
        "--port"
        "8080"
        "--no-auth"
        "--no-tls"
        "/var/log/suricata/eve.json"
      ];
      ports = [ "127.0.0.1:${toString port}:8080" ];
      volumes = [
        "/var/log/suricata:/var/log/suricata:ro"
        "/var/lib/evebox:/var/lib/evebox"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/evebox 0755 root root -"
  ];
}
