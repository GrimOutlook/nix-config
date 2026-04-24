{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.lang.python;
in
{
  options.host.dev.lang.python.enable = lib.mkEnableOption "Enable Python language support";

  config = lib.mkIf cfg.enable {
    # Enable nix-ld for easier uv use
    programs.nix-ld.enable = true;

    host.home-manager.config = {
      home = {
        packages = with pkgs; [
          python3
        ];

        sessionVariables =
          let
            inherit (config.host.owner) username;
          in
          {
            MYPY_CACHE_DIR = "${config.home-manager.users.${username}.xdg.cacheHome}/mypy";
            PYTHON_HISTORY = "${config.home-manager.users.${username}.xdg.dataHome}/python_history";
          };
      };

      programs = {
        ruff = {
          enable = true;

          settings = {
            line-length = 100;
          };
        };
        uv.enable = true;

        nixvim = {
          files."after/ftplugin/python.lua" = {
            keymaps = [
              {
                mode = "n";
                key = "<leader>i";
                action.__raw = ''
                  function()
                    vim.lsp.buf.code_action {
                      context = {only = {"source.fixAll.ruff"}},
                      apply = true
                    }
                  end
                '';
                options.silent = true;
              }
            ];
          };
          lsp.servers = {
            ruff.enable = true;
            ty.enable = true;
          };
        };
      };
    };
  };
}
