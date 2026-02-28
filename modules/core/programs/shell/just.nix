{ inputs, ... }:
{
  flake.modules.nixos.core =
    {
      config,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        just # Handy way to save and run project-specific commands
      ];

      environment.shellAliases = {
        j = "just";
      };

      programs.bash.interactiveShellInit = ''
        eval "$(just --completions bash)"

        # Use `just` bash-completion function (`_just`) for the alias
        # we made for it (`j`).
        complete -F _just j
      '';
    };
}
