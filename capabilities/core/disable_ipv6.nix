{ config, lib, ... }:
let
  cfg = config.host.disable_ipv6;
in
{
  options.host.disable_ipv6 = {
    enable = lib.mkEnableOption "Enable configurations to disable ipv6";
  };
  config = lib.mkIf cfg.enable {
    # IPv6 sucks and breaks things
    networking.enableIPv6 = false;
    boot.kernelParams = [ "ipv6.disable=1" ];
  };
}
