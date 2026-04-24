{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.lang.shell;
in
{
  options.host.dev.lang.shell.enable = lib.mkEnableOption "Enable shell (bash/sh) language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim = {
      extraPackages = with pkgs; [
        shellcheck
        shfmt
      ];
      lsp.servers.bashls.enable = true;
    };
  };
}
