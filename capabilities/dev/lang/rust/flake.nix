{
  description = "nRF52840 Rust Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      devshell,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            devshell.overlays.default
          ];
        };

        rustToolchain = pkgs.rust-bin.nightly.latest.default;
      in
      {
        devShells.default = pkgs.devshell.mkShell {
          env = [
            # {
            #   name = "RUST_LOG";
            #   value = "debug";
            # }
            {
              name = "PATH";
              prefix = "$HOME/.cargo/bin/";
            }
          ];

          devshell.packages =
            with pkgs;
            [
              rustToolchain

              # I'm surprised this isn't included in the rustToolchain as a
              # dependency but whatever 🤷
              gcc

              # Cargo wrapper that enforces a cooldown window for freshly
              # published crates on crates.io for improved supply chain security.
              # https://github.com/dertin/cargo-cooldown
              # cargo-cooldown

              # # Cryptographically verifiable code review system for the cargo
              # # (Rust) package manager
              # # https://github.com/crev-dev/cargo-crev
              # cargo-crev

              # # Find unused dependencies in Cargo.toml
              # # https://github.com/est31/cargo-udeps
              # cargo-udeps

              # # Heap memory profiler for Linux
              # # https://github.com/KDE/heaptrack
              # heaptrack
            ]
            ++
              # https://blessed.rs/crates
              [
                # -- -- Linting -- -- #

                # # Scan your Rust crate for semver violations.
                # # https://github.com/obi1kenobi/cargo-semver-checks
                # # NOTE: Apparently this has issues when using nightly rust. Keep
                # # that in mind when enabling this.
                # cargo-semver-checks

                # -- -- Managing Dependencies -- -- #

                # # https://github.com/RustSec/rustsec/tree/main/cargo-audit#rustsec-cargo-audit
                # # Check dependencies for reported security vulnerabilities
                # cargo-audit

                # # https://github.com/EmbarkStudios/cargo-deny#-cargo-deny
                # # Enforce policies on your code and dependencies.
                # cargo-deny

                # # https://github.com/killercup/cargo-edit
                # # Adds 'cargo upgrade' and 'cargo set-version' commands to cargo
                # cargo-edit

                # # https://github.com/onur/cargo-license#cargo-license
                # # Lists licenses of all dependencies
                # cargo-license

                # # https://github.com/kbknapp/cargo-outdated#cargo-outdated
                # # Finds dependencies that have available updates
                # cargo-outdated

                # -- -- Performance -- -- #

                # # For profiling binaries at runtime
                # # https://github.com/flamegraph-rs/flamegraph
                # cargo-flamegraph

                # -- Debugging Macros -- -- #

                # # Cargo subcommand to show result of macro expansion
                # # https://github.com/dtolnay/cargo-expand
                # cargo-expand

                # -- -- Benchmarking -- -- #

                # # Tool for benchmarking compiled binaries (similar to unix time
                # # command but better)
                # # https://github.com/sharkdp/hyperfine#hyperfine
                # hyperfine

                # -- -- Testing -- -- #
                # https://github.com/nextest-rs/nextest
                cargo-nextest
              ];

          commands = [
            {
              category = "develop";
              name = "build";
              command = ''
                echo "=> Building crate"
                cargo build
                echo "=> Finished building crate"
              '';
              help = "Build the crate";
            }
            {
              category = "develop";
              name = "tests";
              command = ''
                echo "=> Testing crate"
                cargo nextest run
                echo "=> Finished testing crate"
              '';
              help = "Test the crate";
            }
            {
              category = "develop";
              name = "lint";
              command = ''
                echo "=> Linting the crate"
                cargo clippy
                echo "=> Finished linting crate"
              '';
              help = "Lint the crate";
            }
            {
              category = "develop";
              name = "fmt";
              command = ''
                echo "=> Formatting the crate"
                cargo fmt -- --edition 2024 --unstable-features
                echo "=> Finished formatting crate"
              '';
              help = "Format the crate";
            }
            {
              category = "develop";
              name = "prerelease";
              command = ''
                echo "=> Running pre-release checks"
                cargo clippy -- -D warnings
                echo "=> Finished prerelease-checks"
              '';
              help = "Run pre-release checks on the crate";
            }
          ];
        };

      }
    );
}
