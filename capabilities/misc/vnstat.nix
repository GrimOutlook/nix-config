{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.vnstat;

  # Shared with node_exporter's textfile collector (enabled below), which
  # scrapes whatever .prom files land here.
  textfileDir = "/var/lib/prometheus-node-exporter-text-files";

  # vnstatd only reports on interfaces already in its on-disk database, and
  # `--add` has to name one explicitly -- there's no "just watch whatever has
  # a default route" mode. Detecting it at service start instead of hardcoding
  # a name avoids repeating dubai's wifi module's exact prior incident: a
  # kernel bump renamed its NIC (wlan0 -> wld0) and stranded a hardcoded name
  # with no traffic. `--add` on an interface already tracked is a harmless
  # no-op (ignored via `|| true`), so this is safe to run on every start.
  addInterface = pkgs.writeShellApplication {
    name = "vnstat-add-default-interface";
    runtimeInputs = [
      pkgs.iproute2
      pkgs.gawk
      pkgs.vnstat
    ];
    text = ''
      iface=$(ip route show default | awk '{print $5; exit}')
      if [ -z "$iface" ]; then
        echo "no default route yet -- nothing to add" >&2
        exit 0
      fi
      vnstat --add -i "$iface" || true
    '';
  };

  # vnstat's own hour/day/month/year buckets are historical (already-closed
  # periods, not a live-updating "now" value), so there is no meaningful
  # sample timestamp to give Prometheus other than the scrape time -- the
  # textfile collector can't backdate samples anyway. Each bucket becomes its
  # own series instead, keyed by a `date` label holding that bucket's own
  # period string, so Grafana can graph vnstat's history as a category axis
  # (one bar per label) rather than a real Prometheus time series.
  exportToTextfile = pkgs.writeShellApplication {
    name = "vnstat-prometheus-export";
    runtimeInputs = [
      pkgs.vnstat
      pkgs.jq
    ];
    text = ''
      tmp="${textfileDir}/vnstat.prom.$$"
      vnstat --json | jq -r '
        def pad2: if . < 10 then "0" + (. | tostring) else (. | tostring) end;
        def line(iface; period; date; rx; tx):
          "vnstat_rx_bytes{interface=\"\(iface)\",period=\"\(period)\",date=\"\(date)\"} \(rx)\nvnstat_tx_bytes{interface=\"\(iface)\",period=\"\(period)\",date=\"\(date)\"} \(tx)";
        .interfaces[] |
        . as $iface |
        (
          ($iface.traffic.hour[]?  | line($iface.name; "hour";  "\(.date.year)-\(.date.month|pad2)-\(.date.day|pad2) \(.time.hour|pad2):\(.time.minute|pad2)"; .rx; .tx)),
          ($iface.traffic.day[]?   | line($iface.name; "day";   "\(.date.year)-\(.date.month|pad2)-\(.date.day|pad2)"; .rx; .tx)),
          ($iface.traffic.month[]? | line($iface.name; "month"; "\(.date.year)-\(.date.month|pad2)"; .rx; .tx)),
          ($iface.traffic.year[]?  | line($iface.name; "year";  "\(.date.year)"; .rx; .tx))
        )
      ' > "$tmp"
      mv "$tmp" "${textfileDir}/vnstat.prom"
    '';
  };
in
{
  options.host.vnstat.enable = lib.mkEnableOption "vnstat-based data usage tracking, exported to Prometheus via the node_exporter textfile collector";

  config = lib.mkIf cfg.enable {
    services.vnstat.enable = true;

    systemd.tmpfiles.rules = [
      # Owned by vnstatd (not root): the export service below runs as that
      # user so it can read /var/lib/vnstat, and needs to write here too.
      "d ${textfileDir} 0755 vnstatd vnstatd -"
    ];

    systemd.services.vnstat = {
      path = [
        pkgs.iproute2
        pkgs.vnstat
      ];
      preStart = "${addInterface}/bin/vnstat-add-default-interface";
    };

    systemd.services.vnstat-prometheus-export = {
      description = "Export vnstat's traffic history for node_exporter's textfile collector";
      after = [ "vnstat.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${exportToTextfile}/bin/vnstat-prometheus-export";
        User = "vnstatd";
        Group = "vnstatd";
      };
    };

    systemd.timers.vnstat-prometheus-export = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2m";
        OnUnitActiveSec = "5m";
      };
    };

    services.prometheus.exporters.node.extraFlags = [
      "--collector.textfile.directory=${textfileDir}"
    ];
  };
}
