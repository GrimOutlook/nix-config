{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.misc;
in
{
  options.host.default-programs.misc.enable =
    lib.mkEnableOption "Enable default misc program configurations";

  config = lib.mkIf cfg.enable {
    programs = {
      # Shell extension that manages your environment
      # https://direnv.net/
      direnv = {
        enable = true;
        enableBashIntegration = true;
        # Whether to enable
        # [nix-direnv](https://github.com/nix-community/nix-direnv, a fast,
        # persistent use_nix implementation for direnv.
        nix-direnv.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      # Replacement for a shell history which records additional commands
      # context with optional encrypted synchronization between machines
      # https://github.com/atuinsh/atuin
      atuin

      # Interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands
      # https://dystroy.org/broot/
      broot

      choose # Human-friendly and fast alternative to cut and (sometimes) awk

      # Command line csv viewer
      # https://github.com/YS-L/csvlens
      csvlens

      fastmod # A find and replace tool
      grex # Command-line tool for generating regular expressions from user-provided test cases
      hexyl # Command-line hex viewer
      htmlq # Like jq, but for HTML.
      hyperfine # Command-line benchmarking tool
      imagemagick # Software suite to create, edit, compose, or convert bitmap images
      irssi # Terminal based IRC client    jq # Command-line JSON processor
      lnav # Logfile Navigator
      # TODO: Make `ssh` command tell you to use `mosh`
      mosh # Mobile shell (ssh replacement)
      navi # Interactive cheatsheet tool for the command-line and application launchers
      neofetch # Fast, highly customizable system info script
      openssl # Cryptographic library that implements the SSL and TLS protocols

      pandoc # Conversion between documentation formats
      pastel # Command-line tool to generate, analyze, convert and manipulate colors
      progress # Tool that shows the progress of coreutils programs
      pv # Tool for monitoring the progress of data through a pipeline
      rclone # Command line program to sync files and directories to and from major cloud storage
      rsync # Fast incremental file transfer utility
      sad # CLI tool to search and replace
      sd # Intuitive find & replace CLI (sed alternative)

      # A cli system trash manager, alternative to rm and trash-cli
      # https://github.com/oberblastmeister/trashy
      trashy

      uutils-coreutils-noprefix # Rust remade GNU coreutils. `-noprefix` makes it to where `cat` isn't `uutils-cat`.
      uutils-findutils # Rust remade GNU findutils
      uutils-diffutils # Rust remade GNU diffutils

      xcp # Extended cp(1)
    ];

    environment.shellAliases = {
      benchmark = "hyperfine";
      cdtmp = "cd $(mktemp -d)";
      cp = "xcp --verbose";
      log = "lnav";
      mkdir = "mkdir --parents";
      mv = "mv --progress";
      replace = "fastmod --multiline";
      replace-all = "fastmod --accept-all --print-changed-files --multiline";

      # NOTE: Don't make an `rm` alias. Moving to a new system that doesn't
      # have trashy would result in unintended unrecoverable deletes.
      rt = "trash put";
      tp = "trash put";
    };
  };
}
