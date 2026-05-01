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
        grub = {
          enable = mkDefault true;
          efiSupport = mkDefault true;
          configurationLimit = mkDefault 10;
          device = mkDefault "nodev"; # "nodev" is correct for EFI systems
        };

        efi.canTouchEfiVariables = mkDefault true;

        timeout = mkDefault 2;
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
