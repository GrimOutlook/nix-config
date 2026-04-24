{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
  cfg = config.host.default-programs;
in
{
  options.host.default-programs = {
    enable = mkOption {
      type = types.either types.bool (
        types.enum [
          "all"
          "minimal"
          "none"
        ]
      );
      default = true;
      description = "Enable all default program configurations";
    };
  };
  config =
    let
      enabled = if builtins.isBool cfg.enable then if cfg.enable then "all" else "none" else cfg.enable;
      enableAll =
        modules:
        map (
          module: lib.setAttrByPath [ "host" "default-programs" "${module}" ] { enable = mkDefault true; }
        ) modules;
    in
    lib.mkMerge [
      (mkIf (enabled != "none") (lib.mkMerge (enableAll [
        "core"
      ])))
      (mkIf (enabled == "all") (lib.mkMerge (enableAll [
        "compression"
        "documentation"
        "file-processing"
        "misc"
        "monitoring"
        "networking"
        "searching"
        "shell"
        "storage"
        "troubleshooting"
        "web"
      ])))
    ];
}
