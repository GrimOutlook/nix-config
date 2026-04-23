{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.host.hostname;
in
{
  options.host.hostname = mkOption {
    type = types.string;
    description = "Hostname of the system";
  };

  config.networking.hostName = cfg.hostname;
}
