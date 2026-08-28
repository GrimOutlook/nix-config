{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.display-manager;
  settingsFormat = pkgs.formats.toml { };
in
{
  imports = [
    inputs.nix-config.inputs.noctalia-greeter.nixosModules.default
  ];

  options.host.display-manager = {
    enable = lib.mkEnableOption "Enable display manager (noctalia-greeter)";

    settings = lib.mkOption {
      inherit (settingsFormat) type;
      description = ''
        Rendered to `/var/lib/noctalia-greeter/greeter.toml`. The greeter falls
        back to its own defaults for anything absent, so this only needs to
        carry what differs -- see `examples/greeter.toml` upstream for the full
        set of keys.

        A host that sets this replaces the default wholesale, so a multi-monitor
        host declaring `[output]` has to repeat the keyboard/cursor keys below.
        The option is a plain attrset with no merge function of its own, so two
        partial definitions would collide rather than combine.
      '';
      default = {
        keyboard.layout = "us";
        cursor.size = 24;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Replaced regreet, to match the Noctalia shell the session itself runs.
    # The module turns on greetd and points it at `noctalia-greeter-session`,
    # which brings up the greeter's own wlroots compositor -- unlike regreet it
    # does not need to be launched inside Hyprland, and it takes its monitor
    # layout from `settings.output` rather than from a compositor config.
    #
    # Wallpaper/palette syncing from the shell is a Noctalia v5 feature and we
    # run v4 from nixpkgs, so the greeter's own defaults apply here rather than
    # anything inherited from the session.
    programs.noctalia-greeter = {
      enable = true;
      settings = cfg.settings;
    };
  };
}
