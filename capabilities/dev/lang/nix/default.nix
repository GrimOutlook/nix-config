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

  config.host.home-manager.config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      alejandra
      nix-tree
      nix-output-monitor
      nix-prefetch-github
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

    programs = {
      nix-init = {
        enable = true;
        settings.maintainers = [ "GrimOutlook" ];

      };

      nixvim = {
        lsp.servers.nil_ls = {
          enable = true;
          config.settings.formatting.command = [
            (lib.getExe pkgs.nixfmt)
          ];
        };

        # Set indentation to 2 spaces
        files."after/ftplugin/nix.lua".localOpts = {
          tabstop = 2;
          shiftwidth = 2;
        };

      };
    };
  };
}
