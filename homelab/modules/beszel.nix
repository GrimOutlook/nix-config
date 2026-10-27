# NixOS module (part of the homelab `nixosModules.default`). Managed hosts
# that enable this module run a Beszel agent service that allows the central
# Beszel Hub instance to collect system stats.
{ domains }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.beszel;
in
{
  options.homelab.beszel = {
    agent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable running beszel-agent on this host to ship metrics to Beszel Hub.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 45876;
        description = "Port beszel-agent listens on.";
      };

      key = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "SSH public key provided by the Beszel Hub for agent authentication.";
      };

      keyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to environment file containing KEY=<ssh-public-key>.";
      };
    };

    hubHost = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of the Beszel Hub server.";
    };
  };

  config = lib.mkIf cfg.agent.enable {
    systemd.services.beszel-agent = {
      description = "Beszel Monitoring Agent";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        PORT = toString cfg.agent.port;
      }
      // (lib.optionalAttrs (cfg.agent.key != "") {
        KEY = cfg.agent.key;
      });
      serviceConfig = {
        ExecStart = "${pkgs.beszel}/bin/beszel-agent";
        Restart = "always";
        RestartSec = "5s";
        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
      }
      // (lib.optionalAttrs (cfg.agent.keyFile != null) {
        EnvironmentFile = cfg.agent.keyFile;
      });
    };

    networking.firewall.extraInputRules = "ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 } tcp dport { ${toString cfg.agent.port} } accept";
  };
}
