
{ inputs, lib, config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git # Distributed version control system
  ];

   programs.git = {
    enable = true;
    lfs.enable = true;
    prompt.enable = true;

    # Inspriations:
    # - [@waterkip](https://medium.com/@waterkip/my-git-workflow-7f2c145c9d6d)
    config = {
      core = {
        filemode = false;
        editor = "nvim";
        autocrlf = false;
        eol = "lf";

        # Treat spaces before tabs, and all kinds of trailing whitespace as an error
        whitespace = "space-before-tab,trailing-space";

        logallrefupdates = true;
        # TODO: Figure out how to add this back in
        # excludesfile = ./gitignore;
      };

      interactive = {
        diffFilter = "delta --color-only";
      };

      delta = {
        navigate = true;  # use n and N to move between diff sections
        dark = true;      # or light = true, or omit for auto-detection
      };

      merge ={
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

      init = {
        defaultBranch = "main";
      };

      push = {
        # Push the current branch to a branch of the same name on the remote.
        default = "current";
        autoSetupRemote = true;
      };

      pull = {
        # Avoid creating merge commits in non-main branches.
        rebase = true;
      };

      apply = {
        # Detect whitespace errors when applying a patch
        whitespace = "fix";
      };

      diff = {
        mnemonicprefix = true;
        algorithm = "patience";
        external = "difft";

        # Set difftastic as the default difftool, so we don't need to specify
        # `-t difftastic` every time.
        tool = "difftastic";
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

      color = {
        "branch" = {
          current = "green";
          local   = "yellow";
          remote  = "yellow reverse";
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

      rebase = {
        autoStash = true;
        autosquash =  true;
        forkpoint = false;
      };

      clean = {
        requireForce = true;
      };

      user = {
        name = "Dominic Grimaldi";
        email = "dev@grimoutlook.dev";
      };
      
      commit = {
        # TODO: Add this back in
        # template = ./commit-template;
      };

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
      };
    };
  };
}
