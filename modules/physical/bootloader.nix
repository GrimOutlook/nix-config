{
  flake.modules.nixos.physical =
    { lib, ... }:
    {
      boot = {
        loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
          };

          efi.canTouchEfiVariables = true;

          timeout = lib.mkDefault 10;
        };
        supportedFilesystems = lib.mkForce [
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
