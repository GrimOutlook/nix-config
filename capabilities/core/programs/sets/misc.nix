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
    environment.systemPackages = with pkgs; [
      # Replacement for a shell history which records additional commands
      # context with optional encrypted synchronization between machines
      # https://github.com/atuinsh/atuin
      atuin

      # Interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands
      # https://dystroy.org/broot/
      broot

      # Human-friendly and fast alternative to cut and (sometimes) awk
      # https://github.com/theryangeary/choose
      choose

      # The power of curl, the ease of use of httpie.
      # https://github.com/rs/curlie
      curlie

      # Command line csv viewer
      # https://github.com/YS-L/csvlens
      csvlens

      # Select, put and delete data from JSON, TOML, YAML, XML, INI, HCL and
      # CSV files with a single tool.
      # https://github.com/tomwright/dasel
      dasel

      # A syntax-highlighting pager for git, diff, grep, rg --json, and blame
      # output
      # https://github.com/dandavison/delta
      delta

      # Arbitrary-precision unit-aware calculator
      # https://github.com/printfn/fend
      fend

      # Find files with SQL-like queries
      # https://github.com/jhspetersson/fselect
      fselect

      # Efficient Duplicate File Finder
      # https://github.com/pkolaczk/fclones
      fclones

      fastmod # A find and replace tool
      grex # Command-line tool for generating regular expressions from user-provided test cases

      # A tool for glamorous shell scripts
      # https://github.com/charmbracelet/gum
      gum

      hexyl # Command-line hex viewer
      htmlq # Like jq, but for HTML.
      hyperfine # Command-line benchmarking tool
      imagemagick # Software suite to create, edit, compose, or convert bitmap images
      irssi # Terminal based IRC client

      # Command-line JSON processor
      # https://github.com/jqlang/jq
      jq

      # Scientific calculator with math syntax that supports user-defined
      # variables and functions, complex numbers, and estimation of derivatives
      # and integrals
      # https://github.com/PaddiM8/kalker
      kalker

      # TODO: Make `ssh` command tell you to use `mosh`
      mosh # Mobile shell (ssh replacement)
      navi # Interactive cheatsheet tool for the command-line and application launchers
      neofetch # Fast, highly customizable system info script

      # Command-line Git information tool
      # https://github.com/o2sh/onefetch
      onefetch

      openssl # Cryptographic library that implements the SSL and TLS protocols

      pandoc # Conversion between documentation formats
      pastel # Command-line tool to generate, analyze, convert and manipulate colors

      # # Task management tool for sequential and parallel execution of
      # # long-running tasks
      # # https://github.com/nukesor/pueue
      # pqueue

      progress # Tool that shows the progress of coreutils programs
      pv # Tool for monitoring the progress of data through a pipeline
      rclone # Command line program to sync files and directories to and from major cloud storage
      rsync # Fast incremental file transfer utility
      sad # CLI tool to search and replace
      sd # Intuitive find & replace CLI (sed alternative)

      # A more powerful alternative to sysctl(8) with a terminal user interface
      # 🐧
      # https://github.com/orhun/systeroid
      # TODO: Maybe add alias to override `sysctl`. Or maybe just print a
      # message when using it saying to use this instead.
      systeroid

      # A lightweight TUI application to view and query tabular data files, such as CSV, TSV, and parquet.
      # https://github.com/shshemi/tabiew
      tabiew

      # A cli system trash manager, alternative to rm and trash-cli
      # https://github.com/oberblastmeister/trashy
      trashy

      uutils-coreutils-noprefix # Rust remade GNU coreutils. `-noprefix` makes it to where `cat` isn't `uutils-cat`.
      uutils-findutils # Rust remade GNU findutils
      uutils-diffutils # Rust remade GNU diffutils

      # A terminal spreadsheet multitool for discovering and arranging data
      # https://github.com/saulpw/visidata
      visidata

      # Execute commands in response to file modifications
      # https://github.com/watchexec/watchexec
      watchexec

      xcp # Extended cp(1)

      # Friendly and fast tool for sending HTTP requests
      # https://github.com/ducaale/xh
      xh

      # Command-line YAML, XML, TOML processor - jq wrapper for YAML/XML/TOML documents
      # https://github.com/kislyuk/yq
      yq

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
