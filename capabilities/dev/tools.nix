{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.tools;
in
{
  options.host.dev.tools.enable = lib.mkEnableOption "Enable development tools";

  config = lib.mkIf cfg.enable {
    programs = {
      # Shell extension that manages your environment
      # https://direnv.net/
      direnv = {
        enable = true;
        enableFishIntegration = true;
        # Whether to enable
        # [nix-direnv](https://github.com/nix-community/nix-direnv, a fast,
        # persistent use_nix implementation for direnv.
        nix-direnv.enable = true;
      };
    };

    host.home-manager.config = {
      home = {
        file.".config/direnv/direnvrc".text = ''
          # Place all direnv layouts in the cache directory. This fixes various
          # problems with the `.direnv` directory being scanned when placed
          # in a repo
          direnv_layout_dir() {
            echo "$HOME/.cache/direnv/layouts/$(basename "$PWD")"
          }
        '';
        packages = with pkgs; [
          binwalk

          # Terminal based bitwise calculator in curses
          # https://github.com/mellowcandle/bitwise
          bitwise

          cmake # Cross-platform, open-source build system generator

          # Command line tool for keeping track of what you’re doing and tracking what you’ve done
          # https://github.com/ttscoff/doing/
          doing

          dos2unix # Convert text files with DOS or Mac line breaks to Unix line breaks and vice versa
          mdbook # Create books from MarkDown

          # Preview GitHub README.md files locally before committing them.
          # https://github.com/joeyespo/grip
          grip

          # Modular visual interface for GDB in Python
          # https://github.com/cyrus-and/gdb-dashboard
          gdb-dashboard

          nodejs

          pnpm # Fast, disk space efficient package manager for JavaScript
          ripsecrets # Command-line tool to prevent committing secret keys into your source code

          # A very fast accurate code counter with complexity calculations
          # https://github.com/boyter/scc
          scc

          # Count your code, quickly
          # https://github.com/XAMPPRocky/tokei
          tokei

          xxd
        ];

        shellAliases =
          let
            pnpm-run = "pnpm dlx";
          in
          {
            # Agentic coding tool that lives in your terminal, understands your
            # codebase, and helps you code faster
            # https://github.com/anthropics/claude-code
            claude = "${pnpm-run} @anthropic-ai/claude-code@latest";

            # An open-source AI agent that brings the power of Gemini directly
            # into your terminal.
            # https://github.com/google-gemini/gemini-cli
            gemini = "${pnpm-run} @google/gemini-cli@latest";

            # The open source coding agent.
            # https://github.com/anomalyco/opencode
            opencode = "${pnpm-run} opencode-ai";

            # NOTE: This module requires `fd`/`fdfind` to work fully but that isn't made explicit anywhere.
            # TODO: Make it explicit.
            lf = "fd -t f -x dos2unix {} \\;";
          };
      };
    };
  };
}
