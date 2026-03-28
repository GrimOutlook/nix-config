{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      programs.difftastic = {
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

      programs.git = {
        settings = {
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
}
