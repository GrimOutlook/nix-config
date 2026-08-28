{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.noctalia;
  settingsFormat = pkgs.formats.json { };

  # Relative to the owner's home directory. Noctalia hardcodes this path as
  # its default wallpaper directory, and its wallpaper picker shows an empty
  # list rather than an error when the directory is missing.
  wallpaperDir = "Pictures/Wallpapers";
in
{
  options.host.noctalia = {
    enable = lib.mkEnableOption "Enable the Noctalia desktop shell";

    settings = lib.mkOption {
      inherit (settingsFormat) type;
      description = ''
        Seeded into `~/.config/noctalia/settings.json` on first activation.
        Noctalia fills in every key it doesn't find from its own baked-in
        defaults, so this only needs to carry what differs.

        A host that sets this replaces the default wholesale -- the option is
        a plain JSON attrset, so partial definitions from two places would
        collide rather than merge.
      '';
      default = {
        bar.widgets = {
          left = [
            { id = "ControlCenter"; }
            { id = "Workspace"; }
            { id = "ActiveWindow"; }
          ];
          center = [ { id = "MediaMini"; } ];
          right = [
            { id = "Volume"; }
            {
              id = "SystemMonitor";
              showNetworkStats = true;
            }
            { id = "Battery"; }
            { id = "Tray"; }
            { id = "Clock"; }
            { id = "NotificationHistory"; }
          ];
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    host.home-manager.config =
      # `lib` here is home-manager's extended lib -- `lib.hm.dag` below only
      # exists on this one, not on the NixOS lib above.
      { config, lib, ... }:
      let
        seedFile = settingsFormat.generate "noctalia-settings.json" cfg.settings;
        settingsPath = "${config.xdg.configHome}/noctalia/settings.json";
      in
      {
        home.packages = [ pkgs.noctalia-shell ];

        # Noctalia's wallpaper picker writes the chosen wallpaper back here.
        home.file."${wallpaperDir}/.keep".text = "";

        # Seeded as a real file rather than linked from the store on purpose.
        # Noctalia rewrites settings.json on nearly every start (it stamps the
        # settings version and patches in the resolved avatar/wallpaper/font
        # paths) and on every change made through its settings panel. Pointed
        # at a read-only store path those writes fail silently -- `printErrors`
        # is false on its FileView -- and every setting changed through the GUI
        # would revert on restart. The cost is that edits to `settings` above
        # only reach a host that has no settings.json yet; to re-seed an
        # existing one, delete the file and re-activate.
        home.activation.noctaliaSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -e "${settingsPath}" ]; then
            run mkdir -p "$(dirname "${settingsPath}")"
            run install -m 0644 "${seedFile}" "${settingsPath}"
          fi
        '';

        systemd.user.services.noctalia = {
          Unit = {
            Description = "Noctalia desktop shell (bar, launcher, notifications, wallpaper)";
            Documentation = "https://docs.noctalia.dev";
            PartOf = [ config.wayland.systemd.target ];
            After = [ config.wayland.systemd.target ];
            ConditionEnvironment = "WAYLAND_DISPLAY";
          };

          Service = {
            ExecStart = lib.getExe pkgs.noctalia-shell;
            Restart = "on-failure";
            KillMode = "mixed";
          };

          Install.WantedBy = [ config.wayland.systemd.target ];
        };
      };
  };
}
