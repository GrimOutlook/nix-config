{
  flake.modules.homeManager.dev.programs.nixvim =
    {lib, pkgs, ...}:
    {
      plugins.conform-nvim = {
        enable = true;

        # Whether to enable automatic installation of formatters listed in
        # settings.formatters_by_ft and settings.formatters.
        autoInstall = {
          enable = true;
          enableWarnings = true;
        };

        settings = {
          log_level = "debug";
          notify_on_error = true;
          notify_no_formatters = true;

          format_on_save = {
            lsp_format = "fallback";
            timeout_ms = 500;
          };

          format_after_save = {
            lsp_format = "fallback";
          };

          # TODO: Update the below to function so formatting can be turned off
          # when desired. It's not firing, probably due to an error which is
          # likely the `slow_format_filetypes` not being defined. I think this
          # is supposed to come from lazy but doesn't currently.
          #
          # format_on_save = lib.nixvim.mkRaw ''
          #     function(bufnr)
          #       if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          #         return
          #       end
          #
          #       if slow_format_filetypes[vim.bo[bufnr].filetype] then
          #         return
          #       end
          #
          #       local function on_format(err)
          #         if err and err:match("timeout$") then
          #           slow_format_filetypes[vim.bo[bufnr].filetype] = true
          #         end
          #       end
          #
          #       return { timeout_ms = 200, lsp_fallback = true }, on_format
          #      end
          #   '';
          # NOTE: This is required to exist even if empty to prevent
          # `autoInstall.enable = true` from causing a nix build failure.
          formatters_by_ft = {};
        };
      };

      keymaps = [
        {
          mode = ["n"];
          key = "<leader>F";
          action = "<CMD>lua require('conform').format()<CR>";
          options = {
            desc = "Format File";
          };
        }
      ];
    };
}
