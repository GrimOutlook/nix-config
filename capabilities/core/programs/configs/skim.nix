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
      # Before `zoxide` initialization.
      fish.interactiveShellInit = lib.mkOrder 1900 ''
        source ${pkgs.skim}/share/skim/key-bindings.fish
        skim_key_bindings
      '';
    };
    environment.systemPackages = with pkgs; [
      # Command-line fuzzy finder written in Rust
      # https://github.com/skim-rs/skim
      skim
    ];
  };
}
