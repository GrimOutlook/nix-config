{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.host.dev-tools;
in
{
  options.host.dev-tools.enable = lib.mkEnableOption "Enable development tools";

  config = lib.mkIf cfg.enable {
    host.home-manager = {
      home = {
        packages =
          with pkgs;
          [
            claude-code # Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster
            cmake # Cross-platform, open-source build system generator
            dos2unix # Convert text files with DOS or Mac line breaks to Unix line breaks and vice versa
            mdbook # Create books from MarkDown
            pnpm # Fast, disk space efficient package manager for JavaScript
            ripsecrets # Command-line tool to prevent committing secret keys into your source code
            tokei # Count your code, quickly
          ]
          ++ (with inputs.nixpkgs-unstable; [
            just # Handy way to save and run project-specific commands
          ]);

        shellAliases = {
          # NOTE: This module requires `fd`/`fdfind` to work fully but that isn't made explicit anywhere.
          # TODO: Make it explicit.
          lf = "fd -t f -x dos2unix {} \\;";

          j = "just";
        };
      };

      programs = {
        bash.initExtra = ''
          eval "$(just --completions bash)"

          # Use `just` bash-completion function (`_just`) for the alias
          # we made for it (`j`).
          complete -F _just j
        '';

        # Difftastic configuration
        difftastic = {
          enable = true;
          git = {
            # Whether to enable git integration for difftastic.
            #
            # When enabled, difftastic will be configured as git's external diff
            # tool or difftool depending on the value of
            # {option}`programs.difftastic.git.diffToolMode`.
            enable = true;
            # Whether to additionally configure difftastic as a git difftool.
            #
            # When false, only diff.external is set (used for git diff).
            # When true, both diff.external and difftool config are set (supporting both git diff and git difftool).
            diffToolMode = true;
          };
        };

        git.settings = {
          delta = {
            navigate = true; # use n and N to move between diff sections
            dark = true; # or light = true, or omit for auto-detection
          };

          diff = {
            mnemonicprefix = true;
            algorithm = "patience";
          };

          difftool = {
            # Run the difftool immediately, don't ask 'are you sure' each time.
            prompt = false;
          };

          pager = {
            # Use a pager if the difftool output is larger than one screenful,
            # consistent with the behaviour of `git diff`.
            difftool = true;
          };

          merge = {
            conflictstyle = "zdiff3";
            tool = "diffview";
          };

          mergetool = {
            prompt = false;
            keepBackup = false;
            "diffview" = {
              cmd = ''nvim -n -c 'DiffviewOpen' "$MERGE"'';
              layout = "LOCAL,BASE,REMOTE / MERGED";
            };
          };

          pull = {
            # Avoid creating merge commits in non-main branches.
            rebase = true;
          };

          rebase = {
            autoStash = true;
            autosquash = true;
            forkpoint = false;
          };
        };

        # Jujutsu configuration
        jujutsu = {
          enable = true;

          settings = {
            user = {
              inherit (config.host.home-manager.programs.git.settings.user)
                name
                email
                ;
            };
          };
        };
      };
    };
  };
}
