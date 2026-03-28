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
      ];

      environment.shellAliases = {
        ncdu = alias "dua";

        pkill = alias "pik";
        killall = alias "pik";
      };
    };
}
