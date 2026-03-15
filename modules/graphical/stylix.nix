{ inputs, lib, ... }:
{
  flake.modules.homeManager.graphical =
    { pkgs, ... }:
    {
      imports = [
        inputs.stylix.homeModules.stylix
      ];
      stylix = {
        enable = lib.mkDefault true;
        base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-soft.yaml";
        targets.nixvim.colors.enable = false;
      };
    };
}
