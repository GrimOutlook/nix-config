{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  nc-inputs = inputs.nix-config.inputs;
  cfg = config.host.dev.nixvim.plugins.wayfinder;
in
{

  options.host.dev.nixvim.plugins.wayfinder.enable =
    lib.mkEnableOption "Enable nixvim wayfinder plugin";

  # NOTE: gate the whole `host.home-manager.config` definition, not the value
  # inside it. When nixvim is disabled its home-manager module is never
  # imported, so a `mkIf false` nested *under* `programs.nixvim` would still be
  # a definition of an option that does not exist, and evaluation fails.
  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim = {
      extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "wayfinder-nvim";
          version = "unstable";
          src = nc-inputs.wayfinder-nvim;
        })
      ];

      extraConfigLua = ''
        require('wayfinder').setup({
          performance = "fast",
          scope = {
            mode = "package",
            package_markers = {
              "package.json",
              "tsconfig.json",
              "pyproject.toml",
              "go.mod",
              "Cargo.toml",
              ".git",
            },
          },
          limits = {
            refs = { max_results = 200, timeout_ms = 1200 },
            text = { enabled = true, max_results = 100, timeout_ms = 800 },
            tests = { max_results = 50, timeout_ms = 700 },
            git = { enabled = true, max_commits = 15, timeout_ms = 400 },
          },
        })
      '';

      keymaps = [
        {
          mode = [
            "n"
          ];
          key = "<leader>wf";
          action = "<Plug>(WayfinderOpen)";
          options = {
            desc = "Wayfinder";
          };
        }
        {
          mode = [
            "n"
          ];
          key = "<leader>wtn";
          action = "<Plug>(WayfinderTrailNext)";
          options = {
            desc = "Wayfinder Trail Next";
          };
        }
        {
          mode = [
            "n"
          ];
          key = "<leader>wtp";
          action = "<Plug>(WayfinderTrailPrev)";
          options = {
            desc = "Wayfinder Trail Prev";
          };
        }
        {
          mode = [
            "n"
          ];
          key = "<leader>wto";
          action = "<Plug>(WayfinderTrailOpen)";
          options = {
            desc = "Wayfinder Trail Open";
          };
        }
        {
          mode = [
            "n"
          ];
          key = "<leader>wts";
          action = "<Plug>(WayfinderTrailShow)";
          options = {
            desc = "Wayfinder Trail Show";
          };
        }
      ];
    };
  };
}
