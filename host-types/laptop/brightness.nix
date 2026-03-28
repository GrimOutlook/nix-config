{
  flake.modules.nixos.laptop =
    { lib, pkgs, ... }:
    {
      programs.light = {
        enable = true;
        brightnessKeys.enable = true;
      };
    };
}
