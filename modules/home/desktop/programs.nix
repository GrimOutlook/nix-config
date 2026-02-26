{
  flake.modules.homeManager.desktop-programs =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # IM
        discord
        signal-desktop

        # TODO: Add `zen-browser` to `nixpkgs`
        # zen-browser
        alacritty

        # Misc
        spotify
      ];
    };
}
