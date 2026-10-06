{ config, lib, ... }:
{
  config = lib.mkIf config.host.backup.enable {
    # Firmware default from installer/scan/not-detected.nix, scoped to backups.
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "vmd"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      initrd.kernelModules = [ ];
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
    };
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
