{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.lang.toml;
in
{
  options.host.dev.lang.toml.enable = lib.mkEnableOption "Enable TOML language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim.lsp.servers.tombi.enable = true;
  };
}
