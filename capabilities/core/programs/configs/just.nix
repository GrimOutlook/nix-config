{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.just;
in
{
  options.host.default-program.just.enable = lib.mkEnableOption "Enable default just configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Handy way to save and run project-specific commands
      just
    ];

    environment.shellAliases = {
      j = "just";
      nix-just-init =
        let
          url = "https://raw.githubusercontent.com/GrimOutlook/nix-config/main/just/default.just";
        in
        "curl ${url} > JUSTFILE";
    };

    programs.bash.interactiveShellInit = ''
      eval "$(just --completions bash)"

      # Use `just` bash-completion function (`_just`) for the alias
      # we made for it (`j`).
      complete -F _just j
    '';
  };
}
