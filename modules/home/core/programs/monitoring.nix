{
  flake.modules.homeManager.core = 
    {pkgs, ...}:
    let
      alias = prg: "echo 'Using `${prg}`' && ${prg}";
    in
    {
      home.packages = with pkgs; [
        # CLI utility for displaying current network utilization
        # https://github.com/imsnif/bandwhich
        bandwhich 

        # A minimal, fast alternative to 'du -sh'
        # https://github.com/sharkdp/diskus
        diskus

        # View disk space usage and delete unwanted data, fast.
        # https://github.com/Byron/dua-cli
        dua

        # Process Interactive Kill
        # https://github.com/jacek-kurlit/pik
        pik

        # Fzf terminal UI for systemctl
        # https://github.com/joehillen/sysz
        sysz 

        # A cli system trash manager, alternative to rm and trash-cli
        # https://github.com/oberblastmeister/trashy
        trashy
      ];
      programs = {
        # Monitor of resources
        # https://github.com/aristocratos/btop
        btop = {
          enable = true;

          settings = {
            color_theme = "gruvbox_dark";
            vim_keys = true;
            update_ms = 1000;
            disks_filter = "";
            mem_graphs = false;
            proc_per_core = true;
          };
        };
      };

      home.shellAliases = {
        du = alias "diskus";

        ncdu = alias "dua";

        kill = alias "pik";
        pkill = alias "pik";
        killall = alias "pik";

        # NOTE: Don't make an `rm` alias. Moving to a new system that doesn't
        # have trashy would result in unintended unrecoverable deletes.
        rt = "trashy put";
        tp = "trashy put";
      };
    };
}
