{
  flake.modules = {
    nixos.desktop =
      { pkgs, ... }:
      {
        programs.hyprland.enable = true;
      };
    homeManager.desktop =
      { pkgs, ... }:
      {
        wayland.windowManager.hyprland = {
          enable = true;
          plugins = with pkgs.hyprlandPlugins; [
            hy3
          ];
          settings = {
            # Refer to the wiki for more information.
            # https://wiki.hyprland.org/Configuring/

            # Please note not all available settings / options are set here.
            # For a full list, see the wiki

            # You can split this configuration into multiple files
            # Create your files separately and then link them to this file like this:
            # source = ~/.config/hypr/myColors.conf

            ################
            ### PROGRAMS ###
            ################
            "$fileManager" = "thunar";
            "$menu" = "rofi -show run";
            "$terminal" = "alacritty";

            #################
            ### AUTOSTART ###
            #################

            # Autostart necessary processes (like notifications daemons, status bars, etc.)
            # Or execute your favorite apps at launch like this:

            exec-once = [
              "$terminal"
              "nm-applet &" # Start the NetworkManager tray applet
              "hyprpaper"
              "dunst # Start the notification service"
              "systemctl --user start hyprpolkitagent"
              "wl-paste --type text --watch cliphist store"
              "wl-paste --type image --watch cliphist store"
            ];

            #############################
            ### ENVIRONMENT VARIABLES ###
            #############################

            # See https://wiki.hyprland.org/Configuring/Environment-variables/

            env = [
              "XCURSOR_SIZE,24"
              "HYPRCURSOR_SIZE,24"
            ];

            #####################
            ### LOOK AND FEEL ###
            #####################

            # Refer to https://wiki.hyprland.org/Configuring/Variables/

            # https://wiki.hyprland.org/Configuring/Variables/#general
            general = {
              gaps_in = 5;
              gaps_out = 20;

              border_size = 2;

              # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
              "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
              "col.inactive_border" = "rgba(595959aa)";

              # Set to true enable resizing windows by clicking and dragging on borders and gaps
              resize_on_border = true;
              hover_icon_on_border = true;

              # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
              allow_tearing = false;

              layout = "hy3";
            };

            # https://wiki.hyprland.org/Configuring/Variables/#decoration
            decoration = {
              rounding = 10;
              rounding_power = 2;

              # # Change transparency of focused and unfocused windows
              # active_opacity = 1.0
              # inactive_opacity = 0.90

              shadow = {
                enabled = true;
                range = 4;
                render_power = 3;
                color = "rgba(1a1a1aee)";
              };

              # https://wiki.hyprland.org/Configuring/Variables/#blur
              blur = {
                enabled = true;
                size = 3;
                passes = 1;

                vibrancy = 0.1696;
              };
            };

            # https://wiki.hyprland.org/Configuring/Variables/#animations
            animations = {
              enabled = "yes"; # , please :)
              workspace_wraparound = true;

              # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

              bezier = [
                "easeOutQuint,0.23,1,0.32,1"
                "easeInOutCubic,0.65,0.05,0.36,1"
                "linear,0,0,1,1"
                "almostLinear,0.5,0.5,0.75,1.0"
                "quick,0.15,0,0.1,1"
              ];

              animation = [
                "global, 1, 10, default"
                "border, 1, 5.39, easeOutQuint"
                "windows, 1, 4.79, easeOutQuint"
                "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
                "windowsOut, 1, 1.49, linear, popin 87%"
                "fadeIn, 1, 1.73, almostLinear"
                "fadeOut, 1, 1.46, almostLinear"
                "fade, 1, 3.03, quick"
                "layers, 1, 3.81, easeOutQuint"
                "layersIn, 1, 4, easeOutQuint, fade"
                "layersOut, 1, 1.5, linear, fade"
                "fadeLayersIn, 1, 1.79, almostLinear"
                "fadeLayersOut, 1, 1.39, almostLinear"
                "workspaces, 1, 1.94, almostLinear, fade"
                "workspacesIn, 1, 1.21, almostLinear, fade"
                "workspacesOut, 1, 1.94, almostLinear, fade"
              ];
            };

            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            dwindle = {
              pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
              preserve_split = true; # You probably want this
            };

            # https://wiki.hyprland.org/Configuring/Variables/#misc
            misc = {
              force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
              disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
            };

            #############
            ### INPUT ###
            #############

            # https://wiki.hyprland.org/Configuring/Variables/#input
            input = {
              kb_layout = "us";

              follow_mouse = 1;

              sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

              touchpad = {
                scroll_factor = 0.8;
                natural_scroll = true;
              };
            };

            # https://wiki.hyprland.org/Configuring/Variables/#gestures
            gesture = [
              # Swipe with 3 fingers horizontally to scroll to the next workspace
              "3, horizontal, workspace"
              # Swip up with 3 fingers while holding `SUPER` to make a window fullscreen.
              "3, up, mod: SUPER, scale: 1.5, fullscreen"
            ];

            ################
            ### KEYBINDS ###
            ################
            "$mainMod" = "SUPER"; # `Windows` key is the main modifier.
            bind = [
              "$mainMod, T, exec, $terminal"
              "$mainMod, E, exec, $fileManager"
              "$mainMod, space, exec, $menu"
              "$mainMod, F, togglefloating"
              "$mainMod, escape, killactive, "

              # Move focus with mainMod + vim directions
              "$mainMod, h, hy3:movefocus, l"
              "$mainMod, l, hy3:movefocus, r"
              "$mainMod, k, hy3:movefocus, u"
              "$mainMod, j, hy3:movefocus, d"

              "$mainMod, Tab, hy3:makegroup, tab, toggle, ephemeral"
              "$mainMod SHIFT, Tab, hy3:makegroup, opposite, toggle, ephemeral"

              ", Print, exec, grim -g \"$(slurp -d)\" - | wl-copy"

              # Move window location
              "$mainMod SHIFT, h, hy3:movewindow, l"
              "$mainMod SHIFT, l, hy3:movewindow, r"
              "$mainMod SHIFT, k, hy3:movewindow, u"
              "$mainMod SHIFT, j, hy3:movewindow, d"

              # Switch workspaces with mainMod + [0-9]
              "$mainMod, 1, workspace, 1"
              "$mainMod, 2, workspace, 2"
              "$mainMod, 3, workspace, 3"
              "$mainMod, 4, workspace, 4"
              "$mainMod, 5, workspace, 5"
              "$mainMod, 6, workspace, 6"
              "$mainMod, 7, workspace, 7"
              "$mainMod, 8, workspace, 8"
              "$mainMod, 9, workspace, 9"
              "$mainMod, 0, workspace, 10"

              # Move active window to a workspace with mainMod + SHIFT + [0-9]
              "$mainMod ALT, 1, movetoworkspace, 1"
              "$mainMod ALT, 2, movetoworkspace, 2"
              "$mainMod ALT, 3, movetoworkspace, 3"
              "$mainMod ALT, 4, movetoworkspace, 4"
              "$mainMod ALT, 5, movetoworkspace, 5"
              "$mainMod ALT, 6, movetoworkspace, 6"
              "$mainMod ALT, 7, movetoworkspace, 7"
              "$mainMod ALT, 8, movetoworkspace, 8"
              "$mainMod ALT, 9, movetoworkspace, 9"
              "$mainMod ALT, 0, movetoworkspace, 10"

              # Turn monitors on and off with keybind
              "$mainMod SHIFT, escape, exec, hyprctl dispatch dpms toggle"

              # Example special workspace (scratchpad)
              "$mainMod, s, exec, scratchpad"
              "$mainMod SHIFT, s, exec, scratchpad -g -l -m \"fuzzel --dmenu\""

              # Scroll through existing workspaces with mainMod + scroll
              "$mainMod, mouse_down, workspace, e+1"
              "$mainMod, mouse_up, workspace, e-1"
            ];

            bindm = [

              # Move/resize windows with mainMod + LMB/RMB and dragging
              "$mainMod, mouse:272, movewindow"
              "$mainMod, mouse:273, resizewindow"
            ];

            bindel = [
              # Laptop multimedia keys for volume and LCD brightness
              ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
              ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
              ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
              ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"

            ];

            bindl = [

              # Requires playerctl
              ", XF86AudioNext, exec, playerctl next"
              ", XF86AudioPause, exec, playerctl play-pause"
              ", XF86AudioPlay, exec, playerctl play-pause"
              ", XF86AudioPrev, exec, playerctl previous"
            ];

            ##############################
            ### WINDOWS AND WORKSPACES ###
            ##############################

            # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
            # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

            # Example windowrule
            # windowrule = float,class:^(kitty)$,title:^(kitty)$

            windowrule = [
              # Ignore maximize requests from apps. You'll probably like this.
              "suppressevent maximize, class:.*"

              # Fix some dragging issues with XWayland
              "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
            ];
          };
        };
      };

  };
}
