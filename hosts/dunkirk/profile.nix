{
  config,
  inputs,
  pkgs,
  ...
}:
{
  host = {
    hostname = "dunkirk";
    build-arm.enable = true;
    network-diag.enable = true;
    type.server.enable = true;
    networking.waitOnline = true;
  };
  homelab.scrutiny.collector.enable = true;
  environment.systemPackages = [
    pkgs.zfs
    pkgs.linuxPackages.gasket
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.gasket ];
  boot.kernelModules = [ "apex" ];
  boot.kernel.sysctl = {
    "kernel.panic" = 10;
    "kernel.panic_on_oops" = 1;
  };
  systemd.settings.Manager = {
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "30s";
  };
  host.home-manager.config.imports = [ inputs.homelab.homeManagerModules.default ];
}
