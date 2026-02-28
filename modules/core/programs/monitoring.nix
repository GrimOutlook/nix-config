{
  flake.modules.nixos.core =
    { pkgs, ... }:
    let
      alias = prg: "echo 'Using `${prg}`' && ${prg}";
    in
    {
      environment.systemPackages = with pkgs; [
        # CLI utility for displaying current network utilization
        # https://github.com/imsnif/bandwhich
        bandwhich

        btop

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

      environment.shellAliases = {
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
