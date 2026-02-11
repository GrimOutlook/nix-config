{
  flake.modules.homeManager.core = {
    # Cat(1) clone with syntax highlighting and Git integration
    programs.bat = {
      enable = true;
    };

    home.sessionVariables = {
      MANPAGER = "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'";
    };

    home.shellAliases = {
      cat = "bat -p";
    };
  };
}
