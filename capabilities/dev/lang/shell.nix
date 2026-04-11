{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.lang.shell;
in
{
  options.host.lang.shell.enable = lib.mkEnableOption "Enable shell (bash/sh) language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.programs.nixvim = {
      extraPackages = with pkgs; [
        shellcheck
        shfmt
      ];
      lsp.servers.bashls.enable = true;
    };
  };
}
