# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# The NixOS manual can be gound here: https://nixos.org/manual/nixos/stable/#sec-configuration-syntax

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  security.pki.certificateFiles = [
    ./certs/root-certs.pem
  ];

  # Enable the use of flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    # NOTE: Required for nix flakes to work because flakes clones its dependencies through the git command
    git # Distributed version control system

    # NOTE: Required to import the certificate before building work computers
    cacert

    # -- General tools ---------------------------------------------------------
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
    starship # Minimal, blazing fast, and extremely customizable prompt for any shell
    tmux # Terminal multiplexer
    dust # du, but more intuitive
    duf # Disk Usage/Free Utility
    eza # Modern, maintained replacement for ls
    sad # CLI tool to search and replace
    zoxide # Fast cd command that learns your habits
    # TODO: Make an alias that kills processes using `skim` to search for a name
    skim # Command-line fuzzy finder written in Rust
    procs # Modern replacement for ps written in Rust
    hyperfine # Command-line benchmarking tool
    rip2 # Safe and ergonomic alternative to rm
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
    wikiman # Offline search engine for manual pages, Arch Wiki, Gentoo Wiki and other documentation
    xcp # Extended cp(1)
    watchexec # Executes commands in response to file modifications
    pastel # Command-line tool to generate, analyze, convert and manipulate colors
    ouch # Command-line utility for easily compressing and decompressing files and directories
    gnupg # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation

    # -- Nix tools -------------------------------------------------------------
    nix-index

    # -- Networking ------------------------------------------------------------
    geoip # API for GeoIP/Geolocation databases
    netscanner # Network scanner with features like WiFi scanning, packetdump and more
    ngrep # Network packet analyzer
    rustcat # Port listener and reverse shell
    # TODO: Make an alias that redirects `nmap` to `rustscan`
    rustscan # Faster Nmap Scanning with Rust
    gping # Ping, but with a graph
    # TODO: Make `dig` an alias to `dog`
    dogdns # Command-line DNS client

    # -- Programming -----------------------------------------------------------
    tokei # Count your code, quickly
    git-filter-repo # Quickly rewrite git repository history
    pnpm # Fast, disk space efficient package manager for JavaScript
    just # Handy way to save and run project-specific commands
    dos2unix # Convert text files with DOS or Mac line breaks to Unix line breaks and vice versa
    cmake # Cross-platform, open-source build system generator
    gh # GitHub CLI tool
    delta # Syntax-highlighting pager for git
    jujutsu # Git-compatible DVCS that is both simple and powerful
    mdbook # Create books from MarkDown
    ripsecrets # Command-line tool to prevent committing secret keys into your source code

    dotnet-sdk
    dotnet-runtime
    dotnetPackages.Nuget


  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    configure = {
     # Base config came from https://github.com/nix-community/nixd/blob/main/nixd/docs/editors/nvim-lsp.nix
     customRC = ''
        lua <<EOF
        -------------------
        -- Basic options --
        -------------------
        local options = {
                clipboard = "unnamedplus",
                mouse = "a",
                undofile = true,
                ignorecase = true,
                showmode = false,
                showtabline = 2,
                smartindent = true,
                autoindent = true,
                swapfile = false,
                hidden = true, --default on
                expandtab = true,
                cmdheight = 1,
                shiftwidth = 2, --insert 2 spaces for each indentation
                tabstop = 2, --insert 2 spaces for a tab
                cursorline = true, --Highlight the line where the cursor is located
                cursorcolumn = false,
                number = true,
                numberwidth = 4,
                relativenumber = true,
                scrolloff = 8,
                updatetime = 50, -- faster completion (4000ms default)
                foldmethod = "expr",
                foldexpr = "v:lua.vim.lsp.foldexpr()",
                foldlevel = 99,
                foldenable = true,
        }
        for k, v in pairs(options) do
          vim.opt[k] = v
        end

        ----------------------------
        -- About gruvbox-material --
        ----------------------------
        vim.cmd.colorscheme("gruvbox-material")

        -----------------
        -- About noice --
        -----------------
        require("noice").setup({
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                            { find = "%d fewer lines" },
                            { find = "%d more lines" },
                        },
                    },
                    opts = { skip = true },
                },
            },
        })

        -------------------
        -- About lualine --
        -------------------
        require("lualine").setup({
            options = {
                theme = "auto",
                globalstatus = true,
            },
        })

        ----------------------
        -- About treesitter --
        ----------------------
        require("nvim-treesitter.configs").setup({
                highlight = {
                        enable = true,
                },
                indent = {
                        enable = true,
                },
        })

        EOF
      '';

      packages.all.start = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (ps: [ ps.nix ]))
        gruvbox-material
        nvim-lspconfig
        noice-nvim
        lualine-nvim
      ];
    };
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };
}
