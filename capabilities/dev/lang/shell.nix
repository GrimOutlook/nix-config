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

  config.host.home-manager.config.programs.nixvim = lib.mkIf cfg.enable {
    extraPackages = with pkgs; [
      shellcheck

      # Shell interpreter for docopt, the command-line interface description language.
      # https://github.com/docopt/docopts
      docopts

      shfmt
    ];
    lsp.servers.bashls.enable = true;
  };
}
