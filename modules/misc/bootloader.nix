{
  flake.modules.nixos.bootloader =
    { lib, ... }:
    with lib;
    {
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
