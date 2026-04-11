{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.xdg;
in
{
  options.host.xdg.enable = lib.mkEnableOption "Enable xdg configurations";
  config = lib.mkIf cfg.enable {
    host.home-manager = {
      home = {
        packages = [ pkgs.xdg-utils ];

        # Make programs use XDG directories whenever supported
        preferXdgDirectories = true;
      };

      xdg = {
        enable = true;

        userDirs = {
          enable = true;
        }
        // (lib.mapAttrs (_: folderName: "${config.home.homeDirectory}/${folderName}") {
          desktop = "desktop";
          documents = "documents";
          download = "downloads";
          music = "music";
          pictures = "pictures";
          publicShare = "public";
          templates = "templates";
          videos = "videos";
        });
      };
    };
  };
}
