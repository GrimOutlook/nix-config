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
        "documentation"
        "misc"
        "monitoring"
        "networking"
        "searching"
        "shell"
        "storage"
      ]);
      environment = {
        systemPackages = with pkgs; [
          # Other utils
          mprocs
          nixos-anywhere

          jq

          # Utils
          fclones
          file
          git
          nfs-utils # Linux user-space NFS utilities
          tree
          wget
        ];

        shellAliases = {
          ##################
          # GNU core utils #
          ##################
          rm = "rm -iv";

          ########
          # Misc #
          ########
          t = "date +'%a %b %e %R:%S %Z %Y'";
        };
      };

      # Print's what package (if any) contains the missing command
      programs.command-not-found.enable = true;

      services.vnstat.enable = true;
    };
}
