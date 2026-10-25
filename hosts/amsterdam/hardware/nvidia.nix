# NVIDIA RTX 3050 (Ampere) driver setup.
#
# amsterdam is a headless hypervisor, so this enables only the pieces Plex
# needs for NVENC/NVDEC hardware transcoding - there is no X server or desktop.
{ config, ... }:
{
  # The in-kernel nouveau driver conflicts with the proprietary NVIDIA driver;
  # keep it from binding the card.
  boot.blacklistedKernelModules = [ "nouveau" ];

  hardware = {
    # Exposes the NVIDIA userspace libraries (libnvidia-encode / libnvcuvid)
    # under /run/opengl-driver so the Plex transcoder can find them.
    graphics.enable = true;

    nvidia = {
      # Kernel mode setting is required for the driver to bind the GPU.
      modesetting.enable = true;

      # The RTX 3050 is Ampere and works with the open kernel modules, but the
      # proprietary build remains the safest default for transcoding.
      open = false;

      # Keep the GPU initialised with no client attached so the first transcode
      # after boot doesn't pay device-init latency, and let it drop to low
      # power when idle.
      nvidiaPersistenced = true;
      powerManagement.enable = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Loads the NVIDIA kernel module and userspace driver. This is the supported
  # way to activate the driver on NixOS, headless included.
  services.xserver.videoDrivers = [ "nvidia" ];
}
