{
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [
    # Required by gamescope
    "nvidia_drm.modeset=1"
  ];
  hardware = {
    # Enable graphics card
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      powerManagement.enable = true;
      # Wayland requires kernel mode setting (KMS) to be enabled
      modesetting.enable = true;
      # Use the open source version of the NVIDIA driver (not neouveau btw
      # still unfree due to the user space part of the driver is still
      # proprietary)
      open = false;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
