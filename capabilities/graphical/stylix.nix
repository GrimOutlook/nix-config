{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.host.stylix;
in
{
  options.host.stylix.enable = lib.mkEnableOption "Enable stylix theming";

  config = lib.mkIf cfg.enable {
    host.home-manager = {
      imports = [
        inputs.stylix.homeModules.stylix
      ];
      stylix = {
        enable = lib.mkDefault true;
        base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-soft.yaml";
        targets.nixvim.colors.enable = false;
      };
    };
  };
}
