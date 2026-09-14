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

  # Name of the colour scheme generated from the stylix palette. Noctalia
  # discovers user schemes by scanning `$XDG_CONFIG_HOME/noctalia/colorschemes`
  # with `find -L ... -mindepth 2`, so the file has to sit one directory deep
  # and is named after that directory; the symlink home-manager leaves there is
  # followed thanks to `-L`.
  stylixSchemeName = "Stylix";

  # Whether stylix is wired up for this host at all. Guards every read of the
  # stylix palette below -- `config.lib.stylix.*` only exists once
  # `capabilities/graphical/stylix.nix` has imported the home-manager module.
  stylixCapabilityEnabled = config.host.stylix.enable;
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
        # Short-circuits before touching `config.stylix` on hosts that never
        # imported the module.
        useStylix = stylixCapabilityEnabled && config.stylix.enable;

        # Stylix carries a single palette, so the scheme file gets a single
        # variant. Noctalia falls back to whichever variant is present when the
        # one matching its dark-mode toggle is missing, so flipping dark mode in
        # the shell keeps these colours rather than failing to load.
        variant = if config.stylix.polarity == "light" then "light" else "dark";

        # The base16 -> Noctalia mapping is stylix's own, lifted from its
        # `noctalia-shell` target. That target is inert here: it only writes into
        # `programs.noctalia-shell`, an upstream home-manager module this module
        # deliberately doesn't use (see the settings.json comment below).
        stylixScheme = with config.lib.stylix.colors.withHashtag; {
          ${variant} = {
            mPrimary = base0D;
            mOnPrimary = base00;
            mSecondary = base0E;
            mOnSecondary = base00;
            mTertiary = base0C;
            mOnTertiary = base00;
            mError = base08;
            mOnError = base00;
            mSurface = base00;
            mOnSurface = base05;
            mSurfaceVariant = base01;
            mOnSurfaceVariant = base04;
            mOutline = base03;
            mShadow = base00;
            mHover = base0C;
            mOnHover = base00;

            # Consumed by Noctalia's terminal templates, not by the shell's own
            # chrome. Standard base16 -> ANSI assignment.
            terminal = {
              normal = {
                black = base00;
                red = base08;
                green = base0B;
                yellow = base0A;
                blue = base0D;
                magenta = base0E;
                cyan = base0C;
                white = base05;
              };
              bright = {
                black = base03;
                red = base08;
                green = base0B;
                yellow = base0A;
                blue = base0D;
                magenta = base0E;
                cyan = base0C;
                white = base07;
              };
              foreground = base05;
              background = base00;
              selectionFg = base05;
              selectionBg = base02;
              cursorText = base00;
              cursor = base05;
            };
          };
        };

        stylixSettings = {
          colorSchemes = {
            useWallpaperColors = false;
            predefinedScheme = stylixSchemeName;
            darkMode = variant == "dark";
          };
          ui = {
            fontDefault = config.stylix.fonts.sansSerif.name;
            fontFixed = config.stylix.fonts.monospace.name;
          };
        };

        # `settings` wins over the stylix-derived keys, so a host that wants a
        # different scheme or font can still say so explicitly.
        seedSettings = if useStylix then lib.recursiveUpdate stylixSettings cfg.settings else cfg.settings;

        seedFile = settingsFormat.generate "noctalia-settings.json" seedSettings;
        settingsPath = "${config.xdg.configHome}/noctalia/settings.json";
      in
      {
        home.packages = [ pkgs.noctalia-shell ];

        # Noctalia's wallpaper picker writes the chosen wallpaper back here.
        home.file."${wallpaperDir}/.keep".text = "";

        # Unlike settings.json this *is* linked from the store: Noctalia only
        # reads scheme files, never writes them, so the palette tracks stylix on
        # every rebuild. Only the `predefinedScheme` pointer at it is seeded.
        xdg.configFile."noctalia/colorschemes/${stylixSchemeName}/${stylixSchemeName}.json" =
          lib.mkIf useStylix
            {
              source = settingsFormat.generate "noctalia-${stylixSchemeName}-scheme.json" stylixScheme;
            };

        # Seeded as a real file rather than linked from the store on purpose.
        # Noctalia rewrites settings.json on nearly every start (it stamps the
        # settings version and patches in the resolved avatar/wallpaper/font
        # paths) and on every change made through its settings panel. Pointed
        # at a read-only store path those writes fail silently -- `printErrors`
        # is false on its FileView -- and every setting changed through the GUI
        # would revert on restart. The cost is that edits to `settings` above
        # only reach a host that has no settings.json yet; to re-seed an
        # existing one, delete the file and re-activate. The same applies to the
        # stylix scheme pointer: the scheme file itself always follows stylix,
        # but a host whose settings.json predates this is left pointing at
        # whatever scheme it already had -- pick "Stylix" once in the shell's
        # colour scheme panel, or delete settings.json to re-seed.
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
