{
  flake.modules.homeManager.git = 
    {config, pkgs, ...}:
    {
      home.packages = with pkgs; [
        git-filter-repo # Quickly rewrite git repository history
      ];

      programs = {
        git = {
          enable = true;

          settings = {
            user = {
              email = "dev@grimoutlook.dev";
              name = "Dominic Grimaldi";
            };
          };
        };

        gh = {
          enable = true;

          settings = {
            git_protocol = "ssh";
          };
        };

        lazygit = {
          enable = true;
          settings = {
            gui = {
              theme = {
                activeBorderColor = [
                  "blue"
                  "bold"
                ];
                selectedLineBgColor = [ "white" ];
              };
            };
            git = {
              # Improves performance
              # https://github.com/jesseduffield/lazygit/issues/2875#issuecomment-1665376437
              log.order = "default";

              fetchAll = false;
            };
          };
        };
      };

      home.shellAliases = {
        push = "git push";
        pull = "git pull";
        add = "git add -Av";
        status = "git status";

        s = "git diff HEAD --stat";
        aa = "git add-all";
        send = "git send";
        sp = "git send-please";
      };
    };
}
