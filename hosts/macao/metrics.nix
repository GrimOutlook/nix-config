{
  # Node exporter (config/capabilities/misc/metrics.nix) so newyork's
  # Prometheus can scrape this host's hardware/OS metrics -- see
  # hosts/newyork/modules/services/prometheus.nix's "node" job.
  host.metrics.enable = true;
  # vnstat-based data usage tracking (config/capabilities/misc/vnstat.nix),
  # exported alongside the node exporter's usual metrics.
  host.vnstat.enable = true;

  # This host's flake doesn't wire `homelab` into specialArgs (see
  # flake.nix -- no homelab input at all), so the LAN-allow rule is inlined
  # rather than calling homelab.lib.firewallAllowLocal like the hosts that do
  # have it. Same ranges that helper uses.
  networking.firewall.extraInputRules = ''
    ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } tcp dport { 9100 } accept
  '';
}
