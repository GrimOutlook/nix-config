{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.host.lang.rust;
  fenix-toolchain = inputs.nix-config.inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.host.lang.rust.enable = lib.mkEnableOption "Enable Rust language support";

  config = lib.mkIf cfg.enable {
    host.home-manager = {
      home = {
        packages =
          with pkgs;
          [
            # Cryptographically verifiable code review system for the cargo (Rust) package manager
            # https://github.com/crev-dev/cargo-crev
            cargo-crev

            # Cargo subcommand to show result of macro expansion
            # https://github.com/dtolnay/cargo-expand
            cargo-expand

            # Find unused dependencies in Cargo.toml
            # https://github.com/est31/cargo-udeps
            cargo-udeps

            # For profiling binaries at runtime
            cargo-flamegraph

            # Heap memory profiler for Linux
            heaptrack

            gcc
          ]
          ++ (with fenix-toolchain; [
            # Install all nightly tools that exist in the selected toolchain
            complete.toolchain

            # Install the windows target as well
            targets."x86_64-pc-windows-msvc".latest.toolchain
            targets."x86_64-pc-windows-gnu".latest.toolchain
          ]);

        file.".config/rustfmt/rustfmt.toml".source = ./rustfmt.toml;
      };

      programs.nixvim.plugins = {
        crates.enable = true;
        rustaceanvim = {
          enable = true;
          settings.server.default_settings.rust-analyzer = {
            check.command = "clippy";
            inlayHints.lifetimeElisionHints.enable = "always";
          };
        };
        conform-nvim.settings = {
          formatters_by_ft.rust = [ "rustfmt" ];
          formatters.rustfmt = {
            command = "${fenix-toolchain.complete.rustfmt}/bin/rustfmt";
            args = [
              "--edition"
              "2024"
              "--unstable-features"
            ];
          };
        };
      };
    };
  };
}
