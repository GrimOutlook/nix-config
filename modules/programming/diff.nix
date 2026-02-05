{
flake.modules.homeManager.base.programs = {
    difftastic = { # Syntax-aware diff
      enable = true;

      options.background = "dark";
      git.enable = true;
    };
    git.settings.diff.algorithm = "histogram";
  };
}
