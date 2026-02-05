{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        btop # Monitor of resources
        glances # Cross-platform curses-based monitoring tool
        procs # Modern replacement for ps written in Rust
        sysz # Fzf terminal UI for systemctl

        # TODO: Do we need this?
        lsof
        # TODO: Do we need this?
        psmisc
        # TODO: Do we need this?
        watchexec
      ];

      programs.bottom = {
        enable = true;
        settings = {
          rate = 400;
        };
      };
    };
}
