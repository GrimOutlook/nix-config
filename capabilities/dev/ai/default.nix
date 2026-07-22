{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.ai;
in
{
  imports = [
    ./agy.nix
    ./claude.nix
    ./opencode.nix
  ];

  options.host.dev.ai.enable = lib.mkEnableOption "Enable AI development configurations";

  config =
    let
      enableAll =
        modules:
        map (
          module:
          lib.setAttrByPath (lib.splitString "." "host.dev.ai.${module}") { enable = lib.mkDefault true; }
        ) modules;
    in
    lib.mkIf cfg.enable (
      lib.mkMerge (enableAll [
        "agy"
        "claude"
        "opencode"
      ])
    );
}
