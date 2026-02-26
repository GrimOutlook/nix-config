{ inputs, ... }:
{
  flake.modules.homeManager.dev =
    {
      pkgs,
      config,
      ...
    }:
    let
      fenix-toolchain = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.complete;
    in
    {
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

            gcc
          ]
          ++ (with fenix-toolchain; [
            # Install all nightly tools that exist in the selected toolchain
            toolchain
          ]);

        # By default, it is in ~/.cargo
        sessionVariables.CARGO_HOME = "${config.xdg.dataHome}/cargo";

        file.".config/rustfmt/rustfmt.toml".source = ./rustfmt.toml;
      };

      programs = {
        nixvim = {
          plugins = {
            crates.enable = true;
            rustaceanvim = {
              enable = true;
              settings.server.default_settings.rust-analyzer = {
                check.command = "clippy";
                inlayHints.lifetimeElisionHints.enable = "always";
              };
            };
            conform-nvim = {
              settings = {
                formatters_by_ft = {
                  rust = [ "rustfmt" ];
                };
                formatters = {
                  rustfmt = {
                    command = "${fenix-toolchain.rustfmt}/bin/rustfmt";
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
        };
      };
    };
}
