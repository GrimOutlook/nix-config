{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.host.default-programs;
in
{
  options.host.default-programs.shell.enable = mkEnableOption "Enable default shell configurations";
  config =
    let
      enableAll =
        modules:
        map (
          module: lib.setAttrByPath [ "default-program" "${module}" ] { enable = mkDefault true; }
        ) modules;
    in
    mkIf cfg.enable {
      host = lib.mkMerge (enableAll [
        "atuin"
        "bash"
        "bat"
        "blesh"
        "eza"
        "just"
        "nixvim"
        "skim"
        "ssh"
        "starship"
        "tmux"
        "zoxide"
      ]);
    };
}
