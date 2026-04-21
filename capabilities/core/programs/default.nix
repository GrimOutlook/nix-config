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
      default = mkDefault true;
      description = "Enable all default program configurations";
    };
  };
  config.host =
    let
      enableAll =
        modules:
        map (
          module: lib.setAttrByPath [ "default-programs" "${module}" ] { enable = mkDefault true; }
        ) modules;
    in
    lib.mkMerge (
      (
        mkIf cfg.enable or cfg.enable != "none" (enableAll [
          "core"
        ])
      )
      ++ (
        mkIf cfg.enable or cfg.enable == "all" (enableAll [
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
        ])
      )
    );
}
