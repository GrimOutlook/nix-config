{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      programs.gpg = {
        enable = true;
      };
      services.gpg-agent = {
        enable = true;
        pinentry = {
          package = pkgs.pinentry-curses;
        };
      };
    };
}
