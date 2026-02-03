{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./eza.nix
    ./neovim.nix
    ./starship.nix
    ./tmux/default.nix
  ];

  environment.systemPackages = with pkgs; [
    age # Modern encryption tool with small explicit keys
    bash # GNU Bourne-Again Shell, the de facto standard shell on Linux (for interactive use)
    bat # Cat(1) clone with syntax highlighting and Git integration
    bingrep # Greps through binaries from various OSs and architectures, and colors them
    broot # Interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands
    btop # Monitor of resources
    choose # Human-friendly and fast alternative to cut and (sometimes) awk
    coreutils-full # GNU Core Utilities
    ctop # Top-like interface for container metrics
    curlie # Frontend to curl that adds the ease of use of httpie, without compromising on features and performance
    dive # Tool for exploring each layer in a docker image
    duf # Disk Usage/Free Utility
    dust # du, but more intuitive
    fclones # Efficient Duplicate File Finder and Remover
    fd # Simple, fast and user-friendly alternative to find
    glances # Cross-platform curses-based monitoring tool
    gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
    hexyl # Command-line hex viewer
    htmlq # Like jq, but for HTML.
    hyperfine # Command-line benchmarking tool
    imagemagick # Software suite to create, edit, compose, or convert bitmap images
    irssi # Terminal based IRC client
    jq # Command-line JSON processor
    lnav # Logfile Navigator
    man # Implementation of the standard Unix documentation system accessed using the man command
    man-pages # Linux development manual pages
    # NOTE: This is installed so we can get all available man pages
    man-pages-posix # POSIX man-pages (0p, 1p, 3p)
    micro # Modern and intuitive terminal-based text editor
    # TODO: Make `ssh` command tell you to use `mosh`
    mosh # Mobile shell (ssh replacement)
    navi # Interactive cheatsheet tool for the command-line and application launchers
    neofetch # Fast, highly customizable system info script
    openssl # Cryptographic library that implements the SSL and TLS protocols
    ouch # Command-line utility for easily compressing and decompressing files and directories
    pandoc # Conversion between documentation formats
    pastel # Command-line tool to generate, analyze, convert and manipulate colors
    plocate # Much faster locate
    podman # Program for managing pods, containers and container images
    procs # Modern replacement for ps written in Rust
    progress # Tool that shows the progress of coreutils programs
    rage # A simple, secure and modern file encryption tool (and Rust library) with small explicit keys, no config options, and UNIX-style composability.
    ragenix # Age-encrypted secrets for NixOS, drop-in replacement for agenix
    rclone # Command line program to sync files and directories to and from major cloud storage
    rip2 # Safe and ergonomic alternative to rm
    ripgrep # Utility that combines the usability of The Silver Searcher with the raw speed of grep
    rsync # Fast incremental file transfer utility
    sad # CLI tool to search and replace
    sd # Intuitive find & replace CLI (sed alternative)
    # TODO: Make an alias that kills processes using `skim` to search for a name
    skim # Command-line fuzzy finder written in Rust
    sysz # Fzf terminal UI for systemctl
    tealdeer # Very fast implementation of tldr in Rust
    watchexec # Executes commands in response to file modifications
    wikiman # Offline search engine for manual pages, Arch Wiki, Gentoo Wiki and other documentation
    xcp # Extended cp(1)
    zoxide # Fast cd command that learns your habits
  ];
  
  environment.shellAliases = {
    cat = "bat";
    cp = "xcp";
    docker = "podman";
    log = "lnav";
    mkdir = "mkdir -p";
  };
  
  programs.bash = {
    blesh.enable = true;
    completion.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  programs.zoxide.enable = true;
}
