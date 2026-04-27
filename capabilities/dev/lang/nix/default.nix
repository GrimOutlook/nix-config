{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.lang.nix;
in
{
  options.host.dev.lang.nix.enable = lib.mkEnableOption "Enable Nix language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config = {
      home = {
        packages = with pkgs; [
          alejandra
          nix-tree
          nix-output-monitor
          statix
          patchelf

          # nixpkgs
          hydra-check
          nix-update
          nixpkgs-review
          nixfmt
          nixfmt-tree
          luarocks-packages-updater
          vimPluginsUpdater
        ];

        sessionVariables.NIXPKGS_ALLOW_UNFREE = 1;
      };

      programs = {
        nix-init = {
          enable = true;
          settings = {
            maintainers = [ "GrimOutlook" ];
          };
        };

        nixvim = {
          lsp.servers.nil_ls = {
            enable = true;
            config.settings.formatting.command = [
              (lib.getExe pkgs.nixfmt)
            ];
          };

          files."after/ftplugin/nix.lua" = {
            # Set indentation to 2 spaces
            localOpts = {
              tabstop = 2;
              shiftwidth = 2;
            };
          };
        };
      };
    };
  };
}
