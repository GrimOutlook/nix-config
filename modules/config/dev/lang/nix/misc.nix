{config, ...}:
{
  flake.modules.homeManager.dev = {
    home = {
      sessionVariables.NIXPKGS_ALLOW_UNFREE = 1;
    };
  };
}
