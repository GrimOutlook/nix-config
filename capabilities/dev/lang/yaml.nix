{
  config,
  lib,
  ...
}:
let
  cfg = config.host.lang.yaml;
in
{
  options.host.lang.yaml.enable = lib.mkEnableOption "Enable YAML language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.programs.nixvim.lsp.servers.yamlls.enable = true;
  };
}
