{
  programs = {
    # Enable gamemode for game optimizations
    gamemode.enable = true;

    steam = {
      enable = true;

      # Whether to enable Load the extest library into Steam, to translate X11
      # input events to uinput events (e.g. for using Steam Input on Wayland) .
      extest.enable = true;

      # Open ports in the firewall for Steam Local Network Game Transfers.
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
