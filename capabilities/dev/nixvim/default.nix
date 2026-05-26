{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.nixvim;
in
{
  options.host.dev.nixvim.enable = lib.mkEnableOption "Enable development nixvim configurations";
  config.host = {
    dev.nixvim = lib.mkIf cfg.enable {
      plugins.enable = true;
      # features.enable = true;
    };

    home-manager.config.programs.nixvim = lib.mkIf cfg.enable {
      # A Neovim plugin for integrating Direnv with Neovim.
      plugins.direnv.enable = true;
    };
  };
}
