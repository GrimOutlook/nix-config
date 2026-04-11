{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.lang.java;
in
{
  options.host.lang.java.enable = lib.mkEnableOption "Enable Java language support";

  config = lib.mkIf cfg.enable {
    host.home-manager = {
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
