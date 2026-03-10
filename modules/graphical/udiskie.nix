{
  flake.modules.homeManager.graphical = {
    services.udiskie = {
      enable = true;
      tray = "never";
    };
  };
}
