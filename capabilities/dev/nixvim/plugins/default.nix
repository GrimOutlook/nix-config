{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.nixvim.plugins;
in
{
  options.host.dev.nixvim.plugins.enable =
    lib.mkEnableOption "Enable development nixvim plugin configurations";

  config =
    let
      enableAll =
        modules:
        map (
          module:
          lib.setAttrByPath (lib.splitString "." "host.dev.nixvim.plugins.${module}") {
            enable = lib.mkDefault true;
          }
        ) modules;
    in
    lib.mkIf cfg.enable (
      lib.mkMerge (enableAll [
        "wayfinder"
      ])
    );
}
