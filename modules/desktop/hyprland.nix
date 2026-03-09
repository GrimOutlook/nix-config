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
            "$terminal" = "alacritty";
            "$menu" = "rofi -show run";

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
          };
        };
      };

  };
}
