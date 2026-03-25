{
  flake.modules.homeManager.graphical =
    { pkgs, ... }:
    {
      programs.hyprpanel = {
        enable = true;
        systemd.enable = true;
        settings = {

        };
      };
    };
}
