{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    ;
  cfg = config.host.bootloader;
in
{
  options.host.bootloader.enable = mkEnableOption "Enable bootloader configurations";

  config = mkIf cfg.enable {
    boot = {
      loader = {
        systemd-boot = {
          enable = mkDefault true;
          configurationLimit = mkDefault 10;
        };

        efi.canTouchEfiVariables = mkDefault true;

        timeout = mkDefault 10;
      };
      supportedFilesystems = mkForce [
        "btrfs"
        "reiserfs"
        "vfat"
        "f2fs"
        "xfs"
        "ntfs"
        "cifs"
      ];
    };
  };
}
