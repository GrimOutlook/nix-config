{
  flake.modules.nixos.graphical =
    { pkgs, ... }:
    {
      fonts.packages =
        with pkgs.nerd-fonts;
        [
          jetbrains-mono
          iosevka-term
        ]
        ++ [
          noto-fonts-color-emoji
          font-awesome
        ];
    };
}
