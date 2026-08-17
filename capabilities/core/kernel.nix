{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.kernel;
in
{
  options.host.kernel.enable = lib.mkEnableOption "Enable default kernel configurations";

  config = lib.mkIf cfg.enable {
    # Enable CPU microcode security updates for Intel and AMD processors,
    # along with redistributable hardware firmware. Intel/AMD microcode
    # packages are unavailable outside x86, so gate them by platform --
    # otherwise evaluation fails outright on aarch64 hosts (e.g. dubai).
    hardware.cpu.intel.updateMicrocode = lib.mkIf pkgs.stdenv.hostPlatform.isx86 (
      lib.mkDefault true
    );
    hardware.cpu.amd.updateMicrocode = lib.mkIf pkgs.stdenv.hostPlatform.isx86 (lib.mkDefault true);
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    # Track the newest packaged kernel instead of the release-default one,
    # which otherwise lags behind by a major version or more. `mkDefault` so
    # host.hardening (custom kernel build) and any other host-specific
    # override still win.
    #
    # Skip this on ZFS hosts: OpenZFS routinely lags behind the newest
    # kernel (it's currently broken against linuxPackages_latest), so those
    # hosts need to stay on the release-default kernel nixpkgs knows ZFS
    # supports.
    boot.kernelPackages = lib.mkIf (!config.boot.zfs.enabled) (lib.mkDefault pkgs.linuxPackages_latest);
  };
}
