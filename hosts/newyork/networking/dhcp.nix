# TODO: There might be a way to use Kea for DHCP and then have it run a script
# to add a rule to nftables for port forwards and other things, rather than
# having the `homelab` flake calculate addresses manually.
{
  homelab,
  iface,
  ...
}:
let
  homelib = homelab.lib;
  dhcp = homelab.networking.dhcp;
  local_domain = homelab.domains.local;
in
{
  host.nix.realtimePackages = [ "dnsmasq" ];

  services.dnsmasq = {
    enable = true;
    settings = {
      domain = local_domain;
      local = "/${local_domain}/";
      expand-hosts = true;
      interface = [ iface.lan ];
      dhcp-range = [ "${dhcp.start},${dhcp.end},${dhcp.lease_time}" ];
      dhcp-host = homelib.dhcpHosts;
      # # `dhcp-host` only publishes a DNS entry for a host while it holds an
      # # active DHCP lease. `host-record` isn't tied to lease state, so it
      # # keeps hostnames resolving even for hosts that never use DHCP, or
      # # that stop renewing their lease and freeze at their last address.
      # host-record = homelib.staticHosts;
    };
  };
}
