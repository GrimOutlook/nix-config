{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.lang.core;
in
{
  options.host.dev.lang.core.enable = lib.mkEnableOption "Enable core language support";

  config =
    let
      enableAll =
        modules:
        map (
          module:
          lib.setAttrByPath (lib.splitString "." "host.dev.lang.${module}") { enable = lib.mkDefault true; }
        ) modules;
    in
    lib.mkIf cfg.enable (
      lib.mkMerge (enableAll [
        "shell"
        "toml"
        "xml"
        "yaml"
        # "json"
      ])
    );
}
