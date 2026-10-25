{
  config,
  iface,
  pkgs,
  ...
}:
{
  host.nix.realtimePackages = [ "suricata" ];

  services.suricata = {
    enable = true;

    settings = {
      vars = {
        address-groups = {
          HOME_NET = "[10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16]";
          EXTERNAL_NET = "!$HOME_NET";
        };
      };

      # The bundled suricata-update rules include modbus/dnp3 app-layer-event
      # signatures (beyond the few sids the NixOS module disables by default);
      # with these parsers off, signature loading fails and the service
      # crash-loops. dnp3 needs detection-ports, or it still counts as disabled.
      app-layer.protocols = {
        modbus = {
          enabled = "yes";
          detection-ports.dp = 502;
        };
        dnp3 = {
          enabled = "yes";
          detection-ports.dp = 20000;
        };
      };

      af-packet = [
        {
          interface = iface.wan;
          cluster-id = 99;
          cluster-type = "cluster_flow";
          defrag = true;
        }
      ];

      outputs = [
        {
          fast = {
            enabled = true;
            filename = "/var/log/suricata/fast.log";
            append = true;
          };
        }
        {
          eve-log = {
            enabled = true;
            filetype = "regular";
            filename = "/var/log/suricata/eve.json";
            types = [
              {
                # No `payload`: it embeds the base64 packet payload in every
                # alert, which is most of an alert line's size.
                alert = { };
              }
              {
                anomaly = {
                  enabled = true;
                };
              }
              {
                http = {
                  extended = true;
                };
              }
              {
                dns = {
                  enabled = true;
                };
              }
              {
                tls = {
                  extended = true;
                };
              }
              {
                ssh = {
                  extended = true;
                };
              }
              {
                stats = {
                  totals = true;
                  threads = false;
                  interval = 300;
                };
              }
            ];
          };
        }
      ];
    };
  };

  # Suricata never trims its own logs: eve.json grew ~560 MB/day and filled the
  # 31 GB root in under four weeks. logrotate.timer is hourly, so `maxsize`
  # also bounds a burst day. SIGHUP makes suricata reopen its output files.
  services.logrotate.settings.suricata = {
    files = [
      "/var/log/suricata/*.log"
      "/var/log/suricata/*.json"
    ];
    su = "suricata suricata";
    frequency = "daily";
    maxsize = "500M";
    rotate = 3;
    compress = true;
    delaycompress = true;
    missingok = true;
    notifempty = true;
    sharedscripts = true;
    postrotate = "systemctl kill --signal=HUP suricata.service";
  };

  # Ensure log directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/log/suricata 0755 suricata suricata -"
    "d /var/lib/suricata 0755 suricata suricata -"
  ];
}
