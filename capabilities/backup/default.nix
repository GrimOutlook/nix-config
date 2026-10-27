{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./disko-layout.nix
    ./washington.nix
  ];

  options.host.backup = {
    enable = lib.mkEnableOption "dedicated pull backup host configuration";
    diskDevice = lib.mkOption {
      type = lib.types.str;
      description = "Block device path for the backup host's main disk.";
    };
  };

  config = lib.mkIf config.host.backup.enable {
    host = {
      network-diag.enable = true;
      type.server.enable = true;
      home-manager.config.imports = [ inputs.homelab.homeManagerModules.default ];
    };
    environment.systemPackages = [ pkgs.smartmontools ];
  };
}
