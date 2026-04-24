{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.custom-scripts;
in
{
  options.host.custom-scripts.enable = lib.mkEnableOption "Enable customs script installation";

  config =
    let
      scriptDir = ./scripts;
      scriptNames = builtins.attrNames (
        lib.filterAttrs (name: type: type == "regular") (builtins.readDir scriptDir)
      );
    in
    lib.mkIf cfg.enable {
      environment.shellAliases = {
        macs = ''grep -Po "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})"'';
        ips = ''grep -Po "(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}"'';
        nix-size = "nix path-info --closure-size --human-readable";
      };
      environment.systemPackages =
        with pkgs;
        [
          docopts
        ]
        ++ (map (
          name: pkgs.writeShellScriptBin name (builtins.readFile (scriptDir + "/${name}"))
        ) scriptNames);
    };
}
