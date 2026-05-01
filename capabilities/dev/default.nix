{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev;
in
{
  options.host.dev.enable = lib.mkEnableOption "Enable development configurations";

  config =
    let
      enableAll =
        modules:
        map (
          module:
          lib.setAttrByPath (lib.splitString "." "host.dev.${module}") { enable = lib.mkDefault true; }
        ) modules;
    in
    lib.mkIf cfg.enable (
      lib.mkMerge (enableAll [
        "git"
        "github-cli"
        "diff"
        "jujutsu"
        "lang.core"
        "lazygit"
        "nixvim"
        "tools"
      ])
    );
}
