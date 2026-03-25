{
  flake.modules.nixos.core =
    { pkgs, lib, ... }:
    {
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

        # Command-line fuzzy finder written in Rust
        # https://github.com/skim-rs/skim
        skim = {
          enable = true;
          # Disable default keybindings - we source a patched version that
          # doesn't override git completion (see interactiveShellInit below)
          keybindings = false;
        };
        # After `bash-completion` initialization but before `zoxide`
        # initialization.
        bash.interactiveShellInit = lib.mkOrder 1900 ''
          # Source skim keybindings, then remove git from skim's completions
          # so bash-completion's git completion can work instead
          source ${pkgs.skim}/share/skim/key-bindings.bash
          complete -r git 2>/dev/null
        '';
      };

      environment.systemPackages = with pkgs; [
        age # Modern encryption tool with small explicit keys
        bingrep # Greps through binaries from various OSs and architectures, and colors them

        # Interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands
        # https://dystroy.org/broot/
        broot

        choose # Human-friendly and fast alternative to cut and (sometimes) awk

        # Command line csv viewer
        # https://github.com/YS-L/csvlens
        csvlens

        fastmod # A find and replace tool
        fd # Simple, fast and user-friendly alternative to find
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

        # Painless compression and decompression in the terminal
        # https://github.com/ouch-org/ouch
        ouch

        pandoc # Conversion between documentation formats
        pastel # Command-line tool to generate, analyze, convert and manipulate colors
        plocate # Much faster locate
        progress # Tool that shows the progress of coreutils programs
        rage # A simple, secure and modern file encryption tool (and Rust library) with small explicit keys, no config options, and UNIX-style composability.
        ragenix # Age-encrypted secrets for NixOS, drop-in replacement for agenix
        rclone # Command line program to sync files and directories to and from major cloud storage
        rip2 # Safe and ergonomic alternative to rm
        ripgrep # Utility that combines the usability of The Silver Searcher with the raw speed of grep
        rsync # Fast incremental file transfer utility
        sad # CLI tool to search and replace
        sd # Intuitive find & replace CLI (sed alternative)

        # Command-line fuzzy finder written in Rust
        # https://github.com/skim-rs/skim
        skim

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
        cp = "xcp --verbose";
        log = "lnav";
        mkdir = "mkdir --parents";
        mv = "uutils-mv --progress";
        replace = "fastmod --multiline";
        replace-all = "fastmod --accept-all --print-changed-files --multiline";

        # NOTE: Don't make an `rm` alias. Moving to a new system that doesn't
        # have trashy would result in unintended unrecoverable deletes.
        rt = "trash put";
        tp = "trash put";
      };
    };
}
