{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bash # GNU Bourne-Again Shell, the de facto standard shell on Linux (for interactive use)
      ];
      
      programs.bash = {
        completion.enable = true;
        interactiveShellInit = builtins.readFile ./bashrc.interactive;
      };

      environment.variables = {
        HISTCONTROL = "ignoreboth:erasedups";
        HISTSIZE = 10000;
        HISTFILESIZE = 10000;
      };
    };
}
