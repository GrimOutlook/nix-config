{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        discord

        # Multimedia
        mpv
        vlc
      ];
    };
}
