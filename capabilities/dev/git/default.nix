{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.git;
  hooks_path = ".config/git/hooks";
in
{
  options.host.dev.git.enable = lib.mkEnableOption "Enable Git configuration";

  config.host.home-manager.config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        git-filter-repo # Quickly rewrite git repository history
      ];

      shellAliases = {
        push = "git push";
        pull = "git pull";
        add = "git add -Av";
        status = "git status";

        s = "git diff HEAD --stat";
        st = "git status --short";
        aa = "git add-all";
        send = "git send";
        sp = "git send-please";
      };

      file."${hooks_path}/pre-commit" = {
        executable = true;
        text = ''
          #!/bin/sh
          for hook in ~/${hooks_path}/pre-commit.d/*; do
            if [ -x "$hook" ]; then
              "$hook" "$@" || exit 1
            fi
          done
        '';
      };
    };

    programs = {
      git = {
        enable = true;
        lfs.enable = true;

        settings = {
          user = {
            inherit (config.host.owner) email name;
          };

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
            hooksPath = "~/${hooks_path}";
          };

          init.defaultBranch = "main";

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
            branch = {
              current = "green";
              local = "yellow";
              remote = "yellow reverse";
            };

            diff = {
              meta = "yellow bold";
              frag = "magenta bold";
              old = "red bold";
              new = "green bold";
            };

            status = {
              added = "yellow";
              changed = "green";
              untracked = "cyan";
            };
          };

          remote.pushDefault = "origin";

          advice = {
            statusHints = false;
            detachedHead = false;
          };

          clean.requireForce = true;

          commit.template = builtins.path { path = ./commit-template; };

          alias = {
            ### Human Git
            untracked = "ls-files -o";
            add = "add -v";
            add-all = "add -Av";
            unstage = "restore --staged";
            unadd = "restore --staged";
            untrack = "rm --cached";
            discard = "reset --hard HEAD";
            sweep = "discard";
            uncommit = "reset --soft HEAD^";
            deepclean = "clean -x -ff -dd";
            undo = "checkout --";

            tags = "tag -l";
            remotes = "remote -v";
            stashes = "stash list";

            amend = "commit --amend --reset-author --no-edit";
            nuke = "!git discard && git deepclean";

            precommit = "diff --cached --diff-algorithm=minimal -w";

            send = "push -u origin HEAD";
            send-please = "send --force-with-lease";
            send-NOW = "send --force";

            autosqaush = "rebase --autosqaush";

            # list all defined aliases;
            aliases = "config --get-regexp alias";

            searchfiles = "log --name-status --source --all -S";
            searchtext = "!f() { git grep \"$*\" $(git rev-list --all); }; f";

            graph = "log --graph --pretty=format:'%C(bold red)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(yellow)%ad%Creset %C(bold blue)<%an>%Creset' --abbrev-commit --date=human --decorate=full --all";

            amend-all-and-send-please = "!git add-all && git amend && git send-please";

            new-branch = "!f() { git-new-branch; }; f";

            branches = "branch -a --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
            # /HumanGit;

            wip = "commit -am 'wip!'";
            oops = "!f() {git amend && git pleasesend; }; f";
            l = "graph";
            aasp = "amend-all-and-send-please";
            a = "add-all";
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
      };
    };
  };
}
