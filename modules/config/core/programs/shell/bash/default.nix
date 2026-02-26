{
  flake.modules.homeManager.core =
    {
      pkgs,
      lib,
      ...
    }:
    {
      # GNU Bourne-Again Shell, the de facto standard shell on Linux (for
      # interactive use)
      programs.bash = {
        enable = true;

        initExtra = ''
          ${lib.getExe pkgs.pfetch}
        ''
        + builtins.readFile ./bashrc.interactive;
      };

      home.sessionVariables = {
        HISTCONTROL = "ignoreboth:erasedups";
        HISTSIZE = 10000;
        HISTFILESIZE = 10000;
      };
    };
}
