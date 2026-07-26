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
    host.home-manager.config = {
      home = {
        packages = with pkgs; [
          go
        ];

        sessionVariables =
          let
            inherit (config.host.owner) username;
          in
          {
            GOPATH = "${config.home-manager.users.${username}.home.homeDirectory}/.go";
          };

        sessionPath =
          let
            inherit (config.host.owner) username;
          in
          [
            "${config.home-manager.users.${username}.home.homeDirectory}/.go/bin"
          ];
      };

      programs.nixvim = {
        lsp.servers.gopls.enable = true;
      };
    };
  };
}
