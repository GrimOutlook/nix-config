{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.host.default-programs;
in
{
  options.host.default-programs.enable = mkEnableOption "Enable default program configurations";
  config =
    let
      enableAll =
        modules:
        map (
          module: lib.setAttrByPath [ "default-programs" "${module}" ] { enable = mkDefault true; }
        ) modules;
    in
    mkIf cfg.enable {
      host = lib.mkMerge (enableAll [
        "compression"
        "core"
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
      ]);
      services.vnstat.enable = true;
    };
}
