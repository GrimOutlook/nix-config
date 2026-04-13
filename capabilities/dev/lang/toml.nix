{
  config,
  lib,
  ...
}:
let
  cfg = config.host.lang.toml;
in
{
  options.host.lang.toml.enable = lib.mkEnableOption "Enable TOML language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim.lsp.servers.tombi.enable = true;
  };
}
