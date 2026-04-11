{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.monitoring;
in
{
  options.host.default-programs.monitoring.enable =
    lib.mkEnableOption "Enable default monitoring programs configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # CLI utility for displaying current network utilization
      # https://github.com/imsnif/bandwhich
      bandwhich

      # A monitor of resources
      # https://github.com/aristocratos/btop
      btop

      killall

      # A modern replacement for ps written in Rust
      # https://github.com/dalance/procs
      procs

      # Process Interactive Kill
      # https://github.com/jacek-kurlit/pik
      pik

      systemd-manager-tui

      # Fzf terminal UI for systemctl
      # https://github.com/joehillen/sysz
      sysz

    ];

    environment.shellAliases =
      let
        alias = prg: "echo 'Using `${prg}`' && ${prg}";
      in
      {
        ncdu = alias "dua";
      };
  };
}
