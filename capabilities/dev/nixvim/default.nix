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
  # NOTE: gate the whole `host.home-manager.config` definition, not the value
  # inside it. When nixvim is disabled its home-manager module is never
  # imported, so a `mkIf false` nested *under* `programs.nixvim` would still be
  # a definition of an option that does not exist, and evaluation fails.
  config = lib.mkIf cfg.enable {
    host = {
      dev.nixvim = {
        plugins.enable = true;
        # features.enable = true;
      };

      home-manager.config.programs.nixvim = {
        # A Neovim plugin for integrating Direnv with Neovim.
        plugins.direnv.enable = true;
      };
    };
  };
}
