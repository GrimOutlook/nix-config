{
  config,
  lib,
  ...
}:
let
  cfg = config.host.tmp;
in
{
  options.host.tmp.enable = lib.mkEnableOption "Enable /tmp configurations";

  config = lib.mkIf cfg.enable {
    # /tmp is a plain directory on the root filesystem unless a host says
    # otherwise, so without this it survives reboots and accumulates
    # indefinitely. `mkDefault` so a host can opt out, or switch to
    # `boot.tmp.useTmpfs` instead.
    boot.tmp.cleanOnBoot = lib.mkDefault true;
  };
}
