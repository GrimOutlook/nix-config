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
      nix-just-init =
        let
          url = "https://raw.githubusercontent.com/GrimOutlook/nix-config/main/just/default.just";
        in
        "curl ${url} > JUSTFILE";
    };

    programs.fish.interactiveShellInit = ''
      just --completions fish | source

      # Define `j` as a function so fish completions work (abbr/alias won't).
      function j --wraps just
        just $argv
      end
    '';
  };
}
