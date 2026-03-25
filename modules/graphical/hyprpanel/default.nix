{
  flake.modules.homeManager.graphical =
    { pkgs, lib, ... }:
    {
      programs.hyprpanel = {
        enable = true;
        systemd.enable = true;
        settings = lib.mkForce (import ./_gruvbox/imports.nix { inherit lib; });
      };
    };
}
