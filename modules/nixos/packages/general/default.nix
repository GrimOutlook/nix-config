{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./starship.nix
  ];

  environment.systemPackages = with pkgs; [
    bash
    bat # Cat(1) clone with syntax highlighting and Git integration
    btop # Monitor of resources
    choose # Human-friendly and fast alternative to cut and (sometimes) awk
    ctop # Top-like interface for container metrics
    curlie # Frontend to curl that adds the ease of use of httpie, without compromising on features and performance
    dive # Tool for exploring each layer in a docker image
    fd # Simple, fast and user-friendly alternative to find
    hexyl # Command-line hex viewer
    neovim # Vim text editor fork focused on extensibility and agility
    ripgrep # Utility that combines the usability of The Silver Searcher with the raw speed of grep
    sd # Intuitive find & replace CLI (sed alternative)
    tmux # Terminal multiplexer
    # dust # du, but more intuitive
    duf # Disk Usage/Free Utility
    eza # Modern, maintained replacement for ls
    sad # CLI tool to search and replace
    zoxide # Fast cd command that learns your habits
    # TODO: Make an alias that kills processes using `skim` to search for a name
    skim # Command-line fuzzy finder written in Rust
    procs # Modern replacement for ps written in Rust
    hyperfine # Command-line benchmarking tool
    # rip2 # Safe and ergonomic alternative to rm
    navi # Interactive cheatsheet tool for the command-line and application launchers
    broot # Interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands
    fclones # Efficient Duplicate File Finder and Remover
    jq # Command-line JSON processor
    htmlq # Like jq, but for HTML.
    rage # A simple, secure and modern file encryption tool (and Rust library) with small explicit keys, no config options, and UNIX-style composability.
    glances # Cross-platform curses-based monitoring tool
    lnav # Logfile Navigator
    imagemagick # Software suite to create, edit, compose, or convert bitmap images
    irssi # Terminal based IRC client
    man # Implementation of the standard Unix documentation system accessed using the man command
    man-pages # Linux development manual pages
    man-pages-posix # POSIX man-pages (0p, 1p, 3p)
    # NOTE: This is installed so we can get all available man pages
    coreutils-full # GNU Core Utilities
    progress # Tool that shows the progress of coreutils programs
    # TODO: Make `ssh` command tell you to use `mosh`
    mosh # Mobile shell (ssh replacement)
    micro # Modern and intuitive terminal-based text editor
    neofetch # Fast, highly customizable system info script
    bingrep # Greps through binaries from various OSs and architectures, and colors them
    pandoc # Conversion between documentation formats
    plocate # Much faster locate
    podman # Program for managing pods, containers and container images
    rclone # Command line program to sync files and directories to and from major cloud storage
    rsync # Fast incremental file transfer utility
    sysz # Fzf terminal UI for systemctl
    tealdeer # Very fast implementation of tldr in Rust
    # wikiman # Offline search engine for manual pages, Arch Wiki, Gentoo Wiki and other documentation
    xcp # Extended cp(1)
    watchexec # Executes commands in response to file modifications
    pastel # Command-line tool to generate, analyze, convert and manipulate colors
    ouch # Command-line utility for easily compressing and decompressing files and directories
    gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
  ];
}
