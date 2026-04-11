{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.skim;
in
{
  options.host.default-program.skim.enable = lib.mkEnableOption "Enable default skim configurations";

  config = lib.mkIf cfg.enable {
    programs = {
      # Command-line fuzzy finder written in Rust
      # https://github.com/skim-rs/skim
      skim = {
        enable = true;
        # Disable default keybindings - we source a patched version that
        # doesn't override git completion (see interactiveShellInit below)
        keybindings = false;
      };
      # After `bash-completion` initialization but before `zoxide`
      # initialization.
      bash.interactiveShellInit = lib.mkOrder 1900 ''
        # Source skim keybindings, then remove git from skim's completions
        # so bash-completion's git completion can work instead
        source ${pkgs.skim}/share/skim/key-bindings.bash
        complete -r git 2>/dev/null
      '';
    };
    environment.systemPackages = with pkgs; [
      # Command-line fuzzy finder written in Rust
      # https://github.com/skim-rs/skim
      skim
    ];
  };
}
