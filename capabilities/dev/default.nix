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
        "git"
        "dev.diff"
        "dev.tools"
        "lang.core"
      ])
    );
}
