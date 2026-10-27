{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  host = {
    hostname = "amsterdam";
    build-arm.enable = true;
    network-diag.enable = true;
    type.server.enable = true;
  };
  boot.supportedFilesystems = lib.mkForce {
    btrfs = true;
    reiserfs = true;
    vfat = true;
    f2fs = true;
    xfs = true;
    ntfs = true;
    cifs = true;
    zfs = true;
  };
  homelab.scrutiny.collector.enable = true;
  environment.systemPackages = [ pkgs.zfs ];
  host.home-manager.config.imports = [ inputs.homelab.homeManagerModules.default ];
}
