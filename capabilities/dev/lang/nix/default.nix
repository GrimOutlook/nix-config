{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.lang.nix;
in
{
  options.host.lang.nix.enable = lib.mkEnableOption "Enable Nix language support";

  config = lib.mkIf cfg.enable {
    host.home-manager = {
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

        shellAliases = {
          ur = "${lib.getExe pkgs.fd} --no-ignore --max-depth 1 'result*' --exec unlink";
          nu = "nix-update";
          nuc = "nix-update --commit";
          nucb = "nix-update --commit --build";
        };
      };

      programs = {
        nix-init = {
          enable = true;
          settings = {
            maintainers = [ "GrimOutlook" ];
          };
        };

        bash.shellAliases = {
          nl = "nix log";
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
