{
  flake.modules.nixos.graphical =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs.nerd-fonts; [
        jetbrains-mono
      ];
    };
}
