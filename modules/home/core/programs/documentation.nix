{
  flake.modules.homeManager.core =
    { pkgs, ... }:
    {
      programs = {
        # Very fast implementation of tldr in Rust
        tealdeer = {
          enable = true;
          enableAutoUpdates = true;
        };
        # GNU Info
        info.enable = true;

        man = {
          # Whether to enable manual pages and the {command}man command. This
          # also includes "man" outputs of all home.packages.
          enable = true;
          # Whether to generate the manual page index caches using
          # {manpage}mandb(8). This allows searching for a page or keyword using
          # utilities like {manpage}apropos(1).
          # This feature is disabled by default because it slows down building.
          # If you don't mind waiting a few more seconds when Home Manager
          # builds a new generation, you may safely enable this option.
          generateCaches = true;
        };
      };
    };
}
