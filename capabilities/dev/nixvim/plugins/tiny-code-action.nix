{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  nc-inputs = inputs.nix-config.inputs;
  inherit (nc-inputs.nixvim.lib.nixvim) mkRaw;

  cfg = config.host.dev.nixvim.plugins.tiny-code-action;
in
{
  options.host.dev.nixvim.plugins.tiny-code-action.enable =
    lib.mkEnableOption "Enable nixvim tiny-code-action plugin";

  config.host.home-manager.config.programs.nixvim = lib.mkIf cfg.enable {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "tiny-code-action-nvim";
        version = "unstable";
        src = nc-inputs.tiny-code-action-nvim;
        dependencies = with pkgs.vimPlugins; [ plenary-nvim ];
        nvimSkipModules = [
          # NOTE: Since the snacks previewer isn't used, we don't include
          # snacks as a dependency and so the check fails. We can ignore this
          # check since we don't use it.
          "tiny-code-action.previewers.snacks"
        ];
      })
    ];

    extraConfigLua = ''
      require("tiny-code-action").setup({
        backend = "difftastic",
        picker = {
          "buffer",
          opts = {
            hotkeys = true, -- Enable hotkeys for quick selection of action
            hotkeys_mode = "text_diff_based", -- Modes for generating hotkeys
            auto_preview = false, -- Enable or disable automatic preview
            auto_accept = false, -- Automatically accept the selected action (with hotkeys)
            position = "cursor", -- Position of the picker window
            winborder = "single", -- Border style for picker and preview windows
            keymaps = {
              preview = "K", -- Key to show preview
              close = { "q", "<Esc>" }, -- Keys to close the window (can be string or table)
              select = "<CR>", -- Keys to select action (can be string or table)
              preview_close = { "q", "<Esc>" }, -- Keys to return from preview to main window (can be string or table)
            },
            custom_keys = {
              { key = 'm', pattern = 'Fill match arms' },
              { key = 'r', pattern = 'Rename.*' }, -- Lua pattern matching
            },
            group_icon = " └",
          },
        },
      })
    '';

    keymaps = [
      {
        action = mkRaw ''
          require("tiny-code-action").code_action
        '';
        key = "<leader>a";
        options = {
          desc = "Code Action";
          noremap = true;
          silent = true;
        };
      }
    ];
  };
}
