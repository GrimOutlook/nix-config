{
  boot = {
    # Description of options here: https://www.kernel.org/doc/html/latest/networking/ip-sysctl.html
    kernel.sysctl = {
      # Optimize input packet processing down to one demux for certain kinds of
      # local sockets. Currently we only do this for established TCP and
      # connected UDP sockets.
      #
      # It may add an additional cost for pure routing workloads that reduces
      # overall throughput, in such case you should disable it.
      "ip_early_demux" = false;
    };
  };
  networking = {
  };
}
