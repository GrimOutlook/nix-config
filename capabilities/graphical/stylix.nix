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

  config.host.home-manager.config = lib.mkIf cfg.enable {
    imports = [
      inputs.nix-config.inputs.stylix.homeModules.stylix
    ];
    stylix = {
      enable = lib.mkDefault true;
      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-soft.yaml";
      targets.nixvim.colors.enable = false;
    };
  };
}
