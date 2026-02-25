{
  flake.modules.homeManager.dev =
    {
      pkgs,
      config,
      ...
    }:
    {
      home = {
        packages = with pkgs; [
          cargo
          gcc
          rustc
          rustfmt
        ];

        # By default, it is in ~/.cargo
        sessionVariables.CARGO_HOME = "${config.xdg.dataHome}/cargo";
      };

      programs = {
        nixvim = {
          plugins = {
            rustaceanvim = {
              enable = true;
              settings.server.default_settings.rust-analyzer = {
                check.command = "clippy";
                inlayHints.lifetimeElisionHints.enable = "always";
              };
            };
            conform-nvim = {
              settings.formatters_by_ft = {
                rust = ["rustfmt"];
              };
            };
          };
        };
      };
    };
}
