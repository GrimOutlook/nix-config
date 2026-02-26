{
  flake.modules.homeManager.core = {
    # Fast cd command that learns your habits
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    home.sessionVariables = {
      _ZO_ECHO = 1;
    };

    home.shellAliases = {
      cd = "z";
    };
  };
}
