# NixOS module (part of the homelab `nixosModules.default`). Every managed host
# that imports it runs a Vector agent that reads the host's systemd journal
# and pushes it to the central homelab VictoriaLogs instance (`washington` by
# default). The collector host additionally runs VictoriaLogs itself.
#
# Unlike raw journal forwarding, the shipper runs on the collector too: the
# collector pushing its own journal to its local VictoriaLogs is desirable,
# not a loop.
{ domains, logging }:
{ config, lib, ... }:
let
  cfg = config.homelab.logging;

  # Where services.victorialogs hardcodes its storage (/var/lib/<stateDir>,
  # stateDir defaulting to "victorialogs"). See the fileSystems bind mount
  # below for why this matters.
  stateDirPath = "/var/lib/victorialogs";

  # DNS ("<host>.home.arpa"), not a static homelab.hosts.<host>.net.ip lookup
  # -- only newyork (the router) has one of those registered. Every other
  # managed host, collector included, resolves by its DHCP-assigned hostname
  # instead, same as caddy.nix's reverse-proxy upstreams.
  pushUri = "http://${cfg.host}.${domains.local}:${toString cfg.port}/insert/jsonline?_stream_fields=host,unit&_msg_field=message&_time_field=timestamp";
in
{
  options.homelab.logging = {
    # Enabled by default: importing this module is what makes a host ship its
    # logs, so it should start doing so without extra opt-in.
    enable = lib.mkEnableOption "shipping this host's journal to the homelab VictoriaLogs instance" // {
      default = true;
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = logging.host;
      description = ''
        Hostname of the homelab log collector this host pushes its journal to.
        Must be a host defined in the homelab flake's `hosts`.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = logging.port;
      description = "HTTP port VictoriaLogs listens on at the collector.";
    };

    server.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.networking.hostName == cfg.host;
      defaultText = lib.literalExpression "config.networking.hostName == config.homelab.logging.host";
      description = ''
        Run the VictoriaLogs server on this host. Defaults to true on the collector
        host only, so importing the module elsewhere just ships logs.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/victorialogs";
      description = "Base data directory for VictoriaLogs partitions.";
    };

    retentionPeriod = lib.mkOption {
      type = lib.types.str;
      default = "100y";
      description = "Time-based retention period for VictoriaLogs (100y effectively disables time expiration).";
    };

    maxDiskSpace = lib.mkOption {
      type = lib.types.str;
      default = "950GB";
      description = "Size-based retention limit: older daily partitions are dropped when disk usage reaches this value.";
    };
  };

  config = lib.mkMerge [
    # Log shipper (runs on every importer via Vector).
    (lib.mkIf cfg.enable {
      services.vector = {
        enable = true;
        journaldAccess = true;
        settings = {
          sources.journal = {
            type = "journald";
            current_boot_only = true;
          };
          transforms.enrich = {
            type = "remap";
            inputs = [ "journal" ];
            source = ''
              .host = "${config.networking.hostName}"
              .unit = ._SYSTEMD_UNIT || "unknown"
              .level = .PRIORITY || "info"
              .syslog_identifier = .SYSLOG_IDENTIFIER || "unknown"
            '';
          };
          sinks.victorialogs = {
            type = "http";
            inputs = [ "enrich" ];
            uri = pushUri;
            encoding.codec = "json";
            # /insert/jsonline wants one JSON object per line. Vector's http
            # sink otherwise frames a batch as a single JSON *array*, which
            # VictoriaLogs rejects with "value doesn't contain object; it
            # contains array" -- a 400, which vector treats as non-retriable,
            # so every batch was silently dropped rather than queued.
            framing.method = "newline_delimited";
            request.retry_attempts = 5;
          };
        };
      };
    })

    # Log collector (runs on the collector host only).
    (lib.mkIf cfg.server.enable {
      users.groups.victorialogs = { };
      users.users.victorialogs = {
        isSystemUser = true;
        group = "victorialogs";
        home = lib.mkDefault cfg.dataDir;
        createHome = true;
      };

      services.victorialogs = {
        enable = true;
        listenAddress = ":${toString cfg.port}";
        extraOptions = [
          "-retentionPeriod=${cfg.retentionPeriod}"
          "-retention.maxDiskSpaceUsageBytes=${cfg.maxDiskSpace}"
        ];
      };

      # The upstream module bakes `-storageDataPath=/var/lib/${stateDir}` into
      # ExecStart with no option to point it elsewhere, and victoria-logs
      # exits at startup if extraOptions passes a second -storageDataPath. So
      # a dataDir somewhere else (e.g. a ZFS dataset under /storage) is put in
      # place by bind-mounting it onto the path the module insists on. That
      # also keeps the unit's hardening happy -- StateDirectory= already
      # grants write access to /var/lib/victorialogs, where an arbitrary path
      # would need an extra ReadWritePaths entry.
      fileSystems = lib.mkIf (cfg.dataDir != stateDirPath) {
        ${stateDirPath} = {
          device = cfg.dataDir;
          fsType = "none";
          options = [ "bind" ];
          # The backing mount (e.g. storage-victorialogs.mount) shares no path
          # prefix with this one, so systemd cannot infer the ordering itself.
          depends = [ cfg.dataDir ];
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0750 victorialogs victorialogs -"
      ];

      systemd.services.victorialogs = {
        unitConfig.RequiresMountsFor = [ stateDirPath ];
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "victorialogs";
          Group = "victorialogs";
        };
      };
    })
  ];
}
