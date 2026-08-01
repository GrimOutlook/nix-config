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

  # NOTE: gate the whole `host.home-manager.config` definition, not the value
  # inside it. When nixvim is disabled its home-manager module is never
  # imported, so a `mkIf false` nested *under* `programs.nixvim` would still be
  # a definition of an option that does not exist, and evaluation fails.
  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim = {
      extraPackages = with pkgs; [
        shellcheck

        # Shell interpreter for docopt, the command-line interface description language.
        # https://github.com/docopt/docopts
        docopts

        shfmt
      ];
      lsp.servers.bashls.enable = true;
    };
  };
}
