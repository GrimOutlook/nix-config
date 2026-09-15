{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.lang.go;
in
{
  options.host.dev.lang.go.enable = lib.mkEnableOption "Enable Go language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config =
      # Function form so GOPATH resolves against each user's own home.
      { config, ... }:
      {
        home = {
          packages = with pkgs; [
            go
          ];

          sessionVariables = {
            GOPATH = "${config.home.homeDirectory}/.go";
          };

          sessionPath = [
            "${config.home.homeDirectory}/.go/bin"
          ];
        };

        programs.nixvim = {
          lsp.servers.gopls.enable = true;
        };
      };
  };
}
