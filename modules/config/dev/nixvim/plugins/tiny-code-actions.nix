{ inputs, ... }:
{
  flake.modules.homeManager.dev.programs.nixvim =
    { pkgs, ... }:
    let
      plenary = pkgs.vimUtils.buildVimPlugin {
        pname = "plenary-nvim";
        version = "unstable";
        src = inputs.plenary-nvim;
        # NOTE: Since `plenary` is just a library there is no need to do
        # `requires()` checks
        doCheck = false;
      };

      tiny-code-action = pkgs.vimUtils.buildVimPlugin {
        pname = "tiny-code-action-nvim";
        version = "unstable";
        src = inputs.tiny-code-action-nvim;
        dependencies = [
          plenary
        ];
        nvimSkipModules = [
          # NOTE: Since the snacks previewer isn't used, we don't include
          # snacks as a dependency and so the check fails. We can ignore this
          # check since we don't use it.
          "tiny-code-action.previewers.snacks"
        ];
      };
    in
    {
      extraPlugins = [
        tiny-code-action
      ];
      extraConfigLua = ''
        require("tiny-code-action").setup({
          backend = "difftastic",
          picker = {
            "buffer",
            opts = {
              hotkeys = true, -- Enable hotkeys for quick selection of actions
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
          action = ''<cmd>lua require("tiny-code-action").code_action()<cr>'';
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
