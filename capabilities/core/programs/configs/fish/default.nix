{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.fish;
in
{
  options.host.default-program.fish.enable =
    lib.mkEnableOption "Enable default fish configurations";

  config = lib.mkIf cfg.enable {
    # Smart and user-friendly command line shell
    # https://fishshell.com/
    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        ${lib.getExe pkgs.pfetch}
      ''
      + builtins.readFile ./config.fish;
    };

    # Make fish the default login shell for the owner.
    users.defaultUserShell = pkgs.fish;

    host.home-manager.config.programs.fish.enable = true;
  };
}
