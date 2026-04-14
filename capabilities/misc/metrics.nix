{
  config,
  lib,
  ...
}:
let
  cfg = config.host.metrics;
in
{
  options.host.metrics.enable = lib.mkEnableOption "Enable host metrics configurations";

  config.services.prometheus.exporters.node = lib.mkIf cfg.enable {
    enable = true;
    # For the list of available collectors, run, depending on your install:
    # - Flake-based: nix run nixpkgs#prometheus-node-exporter -- --help
    # - Classic: nix-shell -p prometheus-node-exporter --run "node_exporter --help"
    enabledCollectors = [
      "ethtool"
      "softirqs"
      "systemd"
      "tcpstat"
      "wifi"
    ];
    # You can pass extra options to the exporter using `extraFlags`, e.g.
    # to configure collectors or disable those enabled by default.
    # Enabling a collector is also possible using "--collector.[name]",
    # but is otherwise equivalent to using `enabledCollectors` above.
    extraFlags = [
      "--collector.ntp.protocol-version=4"
      "--no-collector.mdadm"
    ];
  };

}
