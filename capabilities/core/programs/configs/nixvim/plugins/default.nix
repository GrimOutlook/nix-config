{
  config,
  lib,
  ...
}:
let
  cfg = config.host.default-programs.nixvim.plugins;
in
{
  options.host.default-programs.nixvim.plugins.enable =
    lib.mkEnableOption "Enable default nixvim plugin configurations";

  config =
    let
      enableAll =
        modules:
        map (
          module:
          lib.setAttrByPath (lib.splitString "." "host.default-programs.nixvim.plugins.${module}") {
            enable = lib.mkDefault true;
          }
        ) modules;
    in
    lib.mkIf cfg.enable (
      lib.mkMerge (enableAll [
        "blink"
        "fyler"
      ])
    );
}
