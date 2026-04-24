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
          module: lib.setAttrByPath (lib.splitString "." "host.${module}") { enable = lib.mkDefault true; }
        ) modules;
    in
    lib.mkIf cfg.enable (
      lib.mkMerge (enableAll [
        "dev.git"
        "dev.github-cli"
        "dev.diff"
        "dev.jujutsu"
        "dev.just"
        "dev.tools"
        "lang.core"
      ])
    );
}
