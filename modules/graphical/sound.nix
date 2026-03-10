{
  flake.modules.nixos.graphical = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
