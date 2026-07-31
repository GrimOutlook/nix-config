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
      # Discard journal entries older than a month. Without this the only bound
      # is the size cap systemd infers from the filesystem (10% of it), which on
      # a small root partition still lets the journal grow into the gigabytes
      # before anything is dropped.
      MaxRetentionSec=1month
    '';
  };
}
