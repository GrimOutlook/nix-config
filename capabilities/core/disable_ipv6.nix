{
  flake.modules.nixos.core = {
    # IPv6 sucks and breaks things
    networking.enableIPv6 = false;
    boot.kernelParams = [ "ipv6.disable=1" ];
  };
}
