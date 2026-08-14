{
  config,
  lib,
  ...
}:
let
  cfg = config.host.journald;
in
{
  options.host.journald.enable = lib.mkEnableOption "Enable journald configurations";

  config = lib.mkIf cfg.enable {
    services.journald.extraConfig = ''
      # Enforce strict journald storage limits, retention durations, and rate limits to mitigate
      # log-filling denial-of-service attacks.
      SystemMaxUse=100M
      RuntimeMaxUse=100M
      MaxRetentionSec=1d
      MaxLevelStore=info
      RateLimitIntervalSec=30s
      RateLimitBurst=10000
    '';
  };
}
