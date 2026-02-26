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
            cargo-expand
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
