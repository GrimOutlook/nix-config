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

  config.environment = lib.mkIf cfg.enable {
    systemPackages = with pkgs; [
      # Replacement for a shell history which records additional commands
      # context with optional encrypted synchronization between machines
      # https://github.com/atuinsh/atuin
      atuin

      # Interactive tree view, a fuzzy search, a balanced BFS descent and customizable commands
      # https://dystroy.org/broot/
      broot

      # A syntax-highlighting pager for git, diff, grep, rg --json, and blame
      # output
      # https://github.com/dandavison/delta
      delta

      # Arbitrary-precision unit-aware calculator
      # https://github.com/printfn/fend
      fend

      # Efficient Duplicate File Finder
      # https://github.com/pkolaczk/fclones
      fclones

      fastmod # A find and replace tool

      hexyl # Command-line hex viewer
      hyperfine # Command-line benchmarking tool
      imagemagick # Software suite to create, edit, compose, or convert bitmap images
      irssi # Terminal based IRC client

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

      pastel # Command-line tool to generate, analyze, convert and manipulate colors

      # # Task management tool for sequential and parallel execution of
      # # long-running tasks
      # # https://github.com/nukesor/pueue
      # pqueue

      rclone # Command line program to sync files and directories to and from major cloud storage

      # A more powerful alternative to sysctl(8) with a terminal user interface
      # 🐧
      # https://github.com/orhun/systeroid
      # TODO: Maybe add alias to override `sysctl`. Or maybe just print a
      # message when using it saying to use this instead.
      systeroid

      # NixOS vulnerability scanner
      # https://github.com/nix-community/vulnix
      vulnix

      # Execute commands in response to file modifications
      # https://github.com/watchexec/watchexec
      watchexec

      # Other utils
      mprocs
      nixos-anywhere
    ];

    shellAliases = {
      benchmark = "hyperfine";
      replace = "fastmod --multiline";
      replace-all = "fastmod --accept-all --print-changed-files --multiline";
    };
  };
}
