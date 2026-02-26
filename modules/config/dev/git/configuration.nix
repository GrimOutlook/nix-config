{ config, ... }:
{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      programs.git = {
        lfs.enable = true;

        settings = {
          core = {
            filemode = false;
            editor = "nvim";
            # Always change CRLF to LF.
            autocrlf = "input";
            eol = "lf";

            # Treat spaces before tabs, and all kinds of trailing whitespace as an error
            whitespace = "space-before-tab,trailing-space";

            logAllRefUpdates = true;
            attributesFile = builtins.path { path = ./gitattributes; };
            excludesFile = builtins.path { path = ./gitignore; };
          };

          init = {
            defaultBranch = "main";
          };

          push = {
            # Push the current branch to a branch of the same name on the remote.
            default = "current";
            autoSetupRemote = true;
          };

          apply = {
            # Detect whitespace errors when applying a patch
            whitespace = "fix";
          };

          color = {
            "branch" = {
              current = "green";
              local = "yellow";
              remote = "yellow reverse";
            };

            "diff" = {
              meta = "yellow bold";
              frag = "magenta bold";
              old = "red bold";
              new = "green bold";
            };

            "status" = {
              added = "yellow";
              changed = "green";
              untracked = "cyan";
            };
          };

          remote = {
            pushDefault = "origin";
          };

          advice = {
            statusHints = false;
            detachedHead = false;
          };

          clean = {
            requireForce = true;
          };

          commit = {
            template = builtins.path { path = ./commit-template; };
          };
        };
      };
    };
}
