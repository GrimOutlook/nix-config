{
  flake.modules.nixos.display-manager =
    { pkgs, ... }:
    {
      # The theme should be in both sddm.extraPackages and environment.systemPackages.
      # https://wiki.nixos.org/wiki/SDDM_Themes
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
        theme = "Elegant";
      };
    };
}
