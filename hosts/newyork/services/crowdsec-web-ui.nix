{
  config,
  host_info,
  pkgs,
  ...
}:
let
  port =
    if host_info.services ? crowdsec-web-ui then
      host_info.services.crowdsec-web-ui.ports.web.number
    else if host_info.services ? crowdsec_web_ui then
      host_info.services.crowdsec_web_ui.ports.web.number
    else if host_info.services ? crowdsec then
      host_info.services.crowdsec.ports.web.number
    else
      50006;
in
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.crowdsec-web-ui = {
      image = "ghcr.io/theduffman85/crowdsec-web-ui:latest";
      ports = [ "127.0.0.1:${toString port}:3000" ];
      environment = {
        CONFIG_SERVER_PORT = "3000";
        CONFIG_PERSIST_OVERRIDES = "true";
      };
      volumes = [
        "/var/lib/crowdsec-web-ui:/app/data"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/crowdsec-web-ui 0755 root root -"
  ];
}
