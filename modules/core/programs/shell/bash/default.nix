{
  flake.modules.nixos.core =
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

        interactiveShellInit = ''
          ${lib.getExe pkgs.pfetch}
        ''
        + builtins.readFile ./bashrc.interactive;
      };

      environment.sessionVariables = {
        HISTCONTROL = "ignoreboth:erasedups";
        HISTSIZE = 10000;
        HISTFILESIZE = 10000;
      };
    };
}
