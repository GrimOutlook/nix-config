{ lib, ... }:
let
  # Shared monitor configuration for berlin, in Hyprland's `monitor =` syntax:
  # name, mode, position, scale, then optional trailing keyword arguments.
  # Used by both the user Hyprland session and the greetd greeter.
  monitors = [
    "DP-3, 2560x1440@239.99, 0x0, 1"
    # Display Port 2, Highest Preset, To the right of the main screen, no scaling, rotated 270 degrees.
    "DP-2, 2560x1440@239.99, 2560x-1120, 1, transform, 3"
    "DP-1, 2560x1440@239.99, 0x-1440, 1"
  ];

  # noctalia-greeter takes its layout as flat "NAME:value; NAME:value" strings
  # rather than a compositor config, so pull the same fields back out of the
  # lines above instead of writing the layout twice and letting the two drift.
  parse =
    line:
    let
      fields = map lib.strings.trim (lib.splitString "," line);
      # Trailing keyword arguments come in pairs after the first four fields;
      # `transform` is the only one berlin uses.
      transformIdx = lib.lists.findFirstIndex (f: f == "transform") null fields;
    in
    {
      name = builtins.elemAt fields 0;
      position = lib.replaceStrings [ "x" ] [ "," ] (builtins.elemAt fields 2);
      scale = builtins.elemAt fields 3;
      # Hyprland numbers its transforms; the greeter names them in degrees.
      transform =
        {
          "0" = "normal";
          "1" = "90";
          "2" = "180";
          "3" = "270";
        }
        .${if transformIdx == null then "0" else builtins.elemAt fields (transformIdx + 1)};
    };

  parsed = map parse monitors;
  join = f: lib.concatMapStringsSep "; " (m: "${m.name}:${f m}") parsed;
in
{
  host.home-manager.config.wayland.windowManager.hyprland.settings.monitor = monitors;

  # Replaces berlin's old greetd override, which wrapped regreet in a Hyprland
  # instance purely to apply this layout. The greeter runs its own compositor,
  # so it only needs the geometry.
  host.display-manager.settings = {
    keyboard.layout = "us";
    cursor.size = 24;
    output = {
      layout = join (m: m.position);
      transforms = join (m: m.transform);
      scales = join (m: m.scale);
    };
  };
}
