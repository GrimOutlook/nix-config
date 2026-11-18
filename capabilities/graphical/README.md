# Graphical Capabilities

Handles configuration for systems that need a display manager, audio, etc.

## Niri / Look test configuration

On the `test/niri-look` branch, `host.graphical.enable` defaults to Niri with
Look as the launcher. Noctalia still provides the bar, notifications, and
wallpaper. The greeter selects the Niri session; Berlin retains its three-output
layout. Look is pinned through its upstream flake and uses its binary cache.

Keybindings retain Super as the main modifier:

- Super+Space or Alt+Space: toggle Look.
- Super+T / Super+E: terminal / file manager.
- Super+H/J/K/L: focus columns/windows; add Shift to move them.
- Super+1–0: focus workspace; Super+Alt+1–0 moves a window there.
- Super+F: float; Super+Shift+F: fullscreen; Super+Tab: tabbed column.
- Super+R: cycle column width; Super+Shift+E: exit Niri.
- Print: native interactive capture (clipboard and screenshot directory).
- Super+Print: annotate the current clipboard image with Satty after capture.

Niri does not implement the screencopy protocol used by the existing grim/slurp
scripts, so screenshot bindings use native capture instead. Hyprland-specific
hy3 groups and scratchpad bindings have no direct translation in this test.

Host-specific output KDL goes in `host.niri.extraConfig`; extra keybindings go
in `host.niri.extraBinds`. Evaluate/build locally from the wrapper with
`just eval-host HOST` / `just build-host HOST` to use this unpublished branch.
