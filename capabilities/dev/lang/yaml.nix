{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.lang.yaml;
in
{
  options.host.dev.lang.yaml.enable = lib.mkEnableOption "Enable YAML language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim.lsp.servers.yamlls.enable = true;
  };
}
