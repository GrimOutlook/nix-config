{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.host.dev.just;
in
{
  options.host.dev.just.enable = lib.mkEnableOption "Enable just tool configurations";

  config.host.home-manager.config = lib.mkIf cfg.enable {
    home = {
      packages = with inputs.nix-config.inputs.nixpkgs-unstable; [
        just # Handy way to save and run project-specific commands
      ];

      shellAliases.j = "just";
    };

    programs.bash.initExtra = ''
      eval "$(just --completions bash)"

      # Use `just` bash-completion function (`_just`) for the alias
      # we made for it (`j`).
      complete -F _just j
    '';
  };
}
