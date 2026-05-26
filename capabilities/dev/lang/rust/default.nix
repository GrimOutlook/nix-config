{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.lang.rust;
in
{
  options.host.dev.lang.rust.enable = lib.mkEnableOption "Enable Rust language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config = {
      programs.nixvim.plugins = {
        crates.enable = true;
        rustaceanvim = {
          enable = true;
          settings.server.default_settings.rust-analyzer = {
            check.command = "clippy";
            files.exclude = [ ".direnv/" ];
            files.excludeDirs = [ ".direnv" ];
            inlayHints.lifetimeElisionHints.enable = "always";
          };
        };
        conform-nvim.settings = {
          formatters_by_ft.rust = [ "rustfmt" ];
          formatters.rustfmt = {
            command = "rustfmt";
            args = [
              "--edition"
              "2024"
              "--unstable-features"
            ];
            # Prevent `rustfmt` from being installed by default. It should be installed by the project flake.
            package = null;
          };
        };
      };
    };
  };
}
