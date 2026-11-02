{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.niri;
  lookToggle = ''spawn "${pkgs.glib}/bin/gdbus" "call" "--session" "--dest" "com.look.Desktop" "--object-path" "/com/look/Desktop" "--method" "com.look.Desktop.Toggle";'';
in
{
  options.host.niri = {
    enable = lib.mkEnableOption "Enable the Niri scrollable-tiling compositor";
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional Niri KDL configuration, including host output layouts.";
    };
    extraBinds = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional keybindings inside Niri's binds block.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      libnotify
    ];
    security.polkit.enable = true;

    host.home-manager.config = {
      services.polkit-gnome.enable = true;
      xdg.configFile."niri/config.kdl".text = ''
        input {
            keyboard { xkb { layout "us"; }; }
            mouse { accel-profile "flat"; }
            touchpad {
                tap
                natural-scroll
                dwt
            }
            focus-follows-mouse max-scroll-amount="0%"
        }
        layout {
            gaps 10
            default-column-width { proportion 0.5; }
            preset-column-widths {
                proportion 0.33333
                proportion 0.5
                proportion 0.66667
            }
            focus-ring { width 2; }
        }
        prefer-no-csd
        spawn-at-startup "alacritty"
        spawn-at-startup "${pkgs.networkmanagerapplet}/bin/nm-applet"
        ${lib.optionalString config.host.look.enable ''spawn-at-startup "${lib.getExe config.programs.lookapp.package}"''}
        spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--type" "text" "--watch" "${pkgs.cliphist}/bin/cliphist" "store"
        spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--type" "image" "--watch" "${pkgs.cliphist}/bin/cliphist" "store"

        window-rule {
            match app-id="^lookapp$"
            open-floating true
            focus-ring { off; }
            shadow { off; }
        }
        binds {
            ${cfg.extraBinds}
            Mod+T { spawn "alacritty"; }
            Mod+E { spawn "thunar"; }
            ${lib.optionalString config.host.look.enable ''
              Mod+Space allow-inhibiting=false { ${lookToggle} }
              Alt+Space allow-inhibiting=false { ${lookToggle} }
            ''}
            Mod+Escape { close-window; }
            Mod+F { toggle-window-floating; }
            Mod+Shift+F { fullscreen-window; }
            Mod+H { focus-column-left; }
            Mod+L { focus-column-right; }
            Mod+K { focus-window-up; }
            Mod+J { focus-window-down; }
            Mod+Shift+H { move-column-left; }
            Mod+Shift+L { move-column-right; }
            Mod+Shift+K { move-window-up; }
            Mod+Shift+J { move-window-down; }
            Mod+Tab { toggle-column-tabbed-display; }
            Mod+R { switch-preset-column-width; }
            Mod+Shift+Escape { power-off-monitors; }
            Mod+Shift+E { quit; }
            Mod+WheelScrollDown { focus-workspace-down; }
            Mod+WheelScrollUp { focus-workspace-up; }
            XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
            XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
            XF86AudioMicMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
            XF86MonBrightnessUp { spawn "brightnessctl" "s" "10%+"; }
            XF86MonBrightnessDown { spawn "brightnessctl" "s" "10%-"; }
            XF86AudioNext { spawn "playerctl" "next"; }
            XF86AudioPrev { spawn "playerctl" "previous"; }
            XF86AudioPlay { spawn "playerctl" "play-pause"; }
            XF86AudioPause { spawn "playerctl" "play-pause"; }
            ${lib.concatMapStringsSep "\n" (
              n:
              let
                key = if n == 10 then "0" else toString n;
              in
              ''
                Mod+${key} { focus-workspace ${toString n}; }
                Mod+Alt+${key} { move-window-to-workspace ${toString n}; }
              ''
            ) (lib.range 1 10)}
        }
        ${cfg.extraConfig}
      '';
    };
  };
}
