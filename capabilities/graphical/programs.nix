{
  flake.modules.homeManager.graphical =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Terminal
        alacritty

        # File Manager
        xfce.thunar

        # IM
        discord

        # Browser
        # TODO: Add `zen-browser` to `nixpkgs`
        # zen-browser
        firefox

        # Video
        mpv
        vlc

        # Misc
        #spotify
      ];
    };
}
