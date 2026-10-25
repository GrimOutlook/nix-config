# NixOS module (part of the homelab `nixosModules.default`). Managed hosts
# that enable this module run a Scrutiny collector agent service that pushes local
# drive S.M.A.R.T. metrics to the central Scrutiny Hub instance.
{ domains, hosts }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.scrutiny;
  hubHost = cfg.collector.host;
  hubPort = hosts.${hubHost}.services.scrutiny.ports.web.number;
in
{
  options.homelab.scrutiny = {
    collector = {
      enable = lib.mkEnableOption "Scrutiny drive S.M.A.R.T. collector";

      host = lib.mkOption {
        type = lib.types.str;
        description = "Hostname of the Scrutiny Hub server.";
      };
    };
  };

  config = lib.mkIf cfg.collector.enable {
    services.scrutiny.collector = {
      enable = true;
      settings.api.endpoint = "http://${hubHost}.${domains.local}:${toString hubPort}";
    };
  };
}
