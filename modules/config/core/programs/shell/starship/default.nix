{
  flake.modules.homeManager.core =
    { lib, pkgs, ... }:
    {
      programs.starship = {
        enable = true;
        settings = lib.importTOML ./starship.toml;
      };
    };
}
