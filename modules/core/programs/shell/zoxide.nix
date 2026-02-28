{
  flake.modules.nixos.core = {
    # Fast cd command that learns your habits
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    environment.sessionVariables = {
      _ZO_ECHO = 1;
    };

    environment.shellAliases = {
      cd = "z";
    };
  };
}
