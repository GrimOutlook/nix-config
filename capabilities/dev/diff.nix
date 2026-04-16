{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.diff;
in
{
  options.host.dev.diff.enable = lib.mkEnableOption "Enable developer diff configurations";

  config = lib.mkIf cfg.enable {
    host.home-manager.config = {
      home = {
        packages = with pkgs; [
          # A syntax-highlighting pager for git, diff, grep, rg --json, and blame
          # output
          # https://github.com/dandavison/delta
          delta

          # A structural diff that understands syntax
          # https://github.com/Wilfred/difftastic
          difftastic
        ];

        shellAliases = {
          dft = "difft";
        };
      };

      programs = {
        difftastic.enable = true;
        delta = {
          enable = true;
          # Whether to enable git integration for delta.
          #
          # When enabled, delta will be configured as git's pager and diff
          # filter.
          enableGitIntegration = true;

          # Whether to enable jujutsu integration for delta.
          #
          # When enabled, delta will be configured as jujutsus's pager, diff
          # filter, and merge tool.
          enableJujutsuIntegration = true;
        };

        git.settings = {
          alias = {
            commitdiff = "!f() { git rev-list --left-right --pretty=oneline \'$\{1}...$\{2}\'; }; f";
            changedfiles = "diff-tree --no-commit-id -r --name-only";

            # Use difftastic
            dft = "-c diff.external=difft diff";
            dft-prev = "-c diff.external=difft diff HEAD~";
            dshow = "-c diff.external=difft show --ext-diff";
            dlog = "-c diff.external=difft log -p --ext-diff";

            diff-commits = "!f() { git rev-list --left-right --pretty=oneline HEAD...origin; }; f";
            diff-no-comment = "difftool --extcmd 'difft --ignore-comments'";
            diff-prev = "diff HEAD~";
            word-diff = "diff -w --word-diff=color --ignore-space-at-eol";

          };
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
        };
      };
    };
  };
}
