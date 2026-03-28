{ config, ... }:
{
  flake.modules.homeManager.dev = {
    programs.nix-init = {
      enable = true;
      settings = {
        maintainers = [ "GrimOutlook" ];
      };
    };
  };
}
