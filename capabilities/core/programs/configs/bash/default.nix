{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.bash;
in
{
  options.host.default-program.bash.enable = lib.mkEnableOption "Enable default bash configurations";

  config = lib.mkIf cfg.enable {
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

    host.home-manager.config.programs.bash.enable = true;
  };
}
