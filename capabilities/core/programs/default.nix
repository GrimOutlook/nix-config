{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkOption
    optionals
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
      default = mkDefault true;
      description = "Enable all default program configurations";
    };
  };
  config.host =
    let
      enabled = if builtins.isBool cfg.enable then if cfg.enable then "all" else "none" else cfg.enable;
      enableAll =
        modules:
        map (
          module: lib.setAttrByPath [ "default-programs" "${module}" ] { enable = mkDefault true; }
        ) modules;
    in
    lib.mkMerge (
      (optionals (enabled != "none") (enableAll [
        "core"
      ]))
      ++ (optionals (enabled == "all") (enableAll [
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
      ]))
    );
}
