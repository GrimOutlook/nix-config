{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        tealdeer
        man
      ];
      documentation = {
        # GNU Info
        info.enable = true;

        man = {
          # Whether to enable manual pages and the {command}man command. This
          # also includes "man" outputs of all home.packages.
          enable = true;

          # TODO: Make a build target variable and activate this when the
          # target is a `release` build.
          #
          # # Whether to generate the manual page index caches using
          # # {manpage}mandb(8). This allows searching for a page or keyword using
          # # utilities like {manpage}apropos(1).
          # # This feature is disabled by default because it slows down building.
          # # If you don't mind waiting a few more seconds when Home Manager
          # # builds a new generation, you may safely enable this option.
          # generateCaches = true;
        };
      };
    };
}
