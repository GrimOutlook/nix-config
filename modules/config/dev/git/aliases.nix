{ config, ... }:
{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      programs.git = {
        settings = {
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

            commitdiff = "!f() { git rev-list --left-right --pretty=oneline \'$\{1}...$\{2}\'; }; f";
            changedfiles = "diff-tree --no-commit-id -r --name-only";
            searchfiles = "log --name-status --source --all -S";
            searchtext = "!f() { git grep \"$*\" $(git rev-list --all); }; f";

            graph = "log --graph --pretty=format:'%C(bold red)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(yellow)%ad%Creset %C(bold blue)<%an>%Creset' --abbrev-commit --date=human --decorate=full --all";

            diff-commits = "!f() { git rev-list --left-right --pretty=oneline HEAD...origin; }; f";
            diff-no-comment = "difftool --extcmd 'difft --ignore-comments'";
            diff-last-commit = "diff --cached HEAD^";
            word-diff = "diff -w --word-diff=color --ignore-space-at-eol";

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
        };
      };
    };
}
