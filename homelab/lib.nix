# This file tracks functions that are available to flakes importing this one.
{ domains, hosts }:
let
  hostServices = hostConfig: if hostConfig ? services then hostConfig.services else { };
  servicePorts = serviceConfig: if serviceConfig ? ports then serviceConfig.ports else { };
  hasSshPort = hostName: hosts.${hostName} ? services && hosts.${hostName}.services ? sshd;
in
{
  # Return an nftables rule allowing TCP traffic in on the given port.
  # 169.254.0.0/16 (link-local) is included alongside the real LAN ranges
  # because rootless podman containers using pasta hairpin back to their own
  # host through a link-local gateway address (e.g. 169.254.1.2) rather than
  # the host's real LAN IP -- traffic that never leaves the host, but still
  # crosses the standard NixOS firewall on its way in. Without this, a
  # container reaching a service on its own host via `host.containers.internal`
  # gets refused even though the service is otherwise LAN-reachable (hit this
  # with washington's Grafana -> Loki datasource).
  firewallAllowLocal =
    port:
    "ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 } tcp dport { ${builtins.toString port} } accept";

  # Return a list of all ports to be forwarded in the form:
  # ```
  # {
  #   hostname = "myhostname";
  #   ip = "10.0.0.0":
  #   service_name = "myservicename";
  #   host_port = "8080";
  #   public_port = "80";
  # }
  # ```
  forwardPorts =
    let
      hostNames = builtins.attrNames hosts;
      hostEntries = builtins.concatMap (
        hostname:
        let
          host_config = hosts.${hostname};
          services = hostServices host_config;
          serviceNames = builtins.attrNames services;
        in
        builtins.concatMap (
          service_name:
          let
            service = services.${service_name};
            forwardablePorts = builtins.filter (p: service.ports.${p}.forward or false) (
              builtins.attrNames (servicePorts service_name)
            );
          in
          builtins.map (port_name: {
            inherit hostname service_name;
            ip = host_config.net.ip;
            host_port = builtins.toString service.ports.${port_name}.number;
            public_port = builtins.toString service.ports.${port_name}.number;
          }) forwardablePorts
        ) serviceNames
      ) hostNames;
    in
    hostEntries;

  # Return a list of strings, where each string represents an entry into the
  # `dnsmasq` configuration for a given DHCP host.
  dhcpHosts =
    let
      hostNames = builtins.attrNames hosts;
      hostEntries = builtins.map (
        hostname:
        let
          net = hosts.${hostname}.net;
        in
        "${net.mac},${hostname},${net.ip}"
      ) (builtins.filter (hostname: hosts.${hostname}.net ? mac) hostNames);
    in
    hostEntries;

  # Return a list of strings, where each string represents an entry into the
  # `dnsmasq` configuration statically associating a hostname with its IP via
  # `host-record`. Unlike `dhcp-host`, a `host-record` entry isn't tied to an
  # active DHCP lease, so the hostname keeps resolving even if the host isn't
  # using DHCP at all, or if it stops renewing its lease and freezes itself
  # at the address it was last assigned (some devices do this).
  staticHosts =
    let
      hostNames = builtins.attrNames hosts;
    in
    builtins.map (
      hostname: "${hostname},${hostname}.${domains.local},${hosts.${hostname}.net.ip}"
    ) hostNames;

  # Return a list of attribute sets that contains a full domain that caddy
  # needs to forward, and the hostname and port it needs to forward to.
  serviceDomains =
    let
      host_names = builtins.attrNames hosts;
    in
    builtins.concatMap (
      hostname:
      let
        services = hostServices hosts.${hostname};
        service_names = builtins.attrNames services;
      in
      builtins.concatMap (
        service_name:
        let
          ports = servicePorts services.${service_name};
          port_names = builtins.attrNames ports;
        in
        builtins.concatMap
          (
            port_name:
            let
              port = ports.${port_name};
              subdomain = if port ? subdomain then port.subdomain else service_name;
            in
            [
              {
                domain = "${subdomain}.${domains.local}";
                host = hostname;
                port = port.number;
                public = false;
              }
            ]
            ++ (
              if ports.${port_name} ? domain then
                [

                  {
                    domain = "${subdomain}.${port.domain}";
                    host = hostname;
                    port = port.number;
                    public = if port ? public then port.public else false;
                  }
                ]
              else
                [ ]
            )
          )

          # Only get the service domains for ports that list a domain.
          port_names

      ) service_names
    ) host_names;

  # Return a caddy entry for the given service domain.
  caddyEntryForServiceDomain = serviceDomain: {
    ${serviceDomain.domain} = {
      extraConfig = ''
        reverse_proxy ${
          if serviceDomain.public then "" else "@local_only "
        }${serviceDomain.host}:${builtins.toString serviceDomain.port}
      '';
    };
  };

  # Returns the port number for the SSH service on a given host
  sshPort =
    hostName:
    if hasSshPort hostName then hosts.${hostName}.services.sshd.ports.default.number else null;

  # Return the hostnames for all hosts that can be SSH'd into
  sshHosts = builtins.filter (hasSshPort) (builtins.attrNames hosts);

  # Return the hostnames of all hosts that have services associated with them
  serviceHosts = builtins.filter (hostname: hosts.${hostname} ? services) (builtins.attrNames hosts);

  hostIp = hostname: hosts.${hostname}.net.ip;
}
