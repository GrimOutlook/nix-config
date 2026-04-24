{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.lang.java;
in
{
  options.host.dev.lang.java.enable = lib.mkEnableOption "Enable Java language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config = {
      home.packages = with pkgs; [
        google-java-format
      ];

      programs.nixvim = {
        lsp.servers.jdtls.enable = true;
        plugins.conform-nvim.settings.formatters_by_ft.java = [ "google-java-format" ];
      };
    };
  };
}
