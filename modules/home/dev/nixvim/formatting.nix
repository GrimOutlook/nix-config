{
  flake.modules.homeManager.dev.programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;

      # TODO: Determine why the below block results in the build failing
      #
      # # Whether to enable automatic installation of formatters listed in
      # # settings.formatters_by_ft and settings.formatters.
      # autoInstall = {
      #   enable = true;
      #   enableWarnings = true;
      # };


      settings = {
        log_level = "info";
        format_on_save = # Lua
          ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end
    
              if slow_format_filetypes[vim.bo[bufnr].filetype] then
                return
              end
    
              local function on_format(err)
                if err and err:match("timeout$") then
                  slow_format_filetypes[vim.bo[bufnr].filetype] = true
                end
              end
    
              return { timeout_ms = 200, lsp_fallback = true }, on_format
             end
          '';
      };
    };

    # keymaps = [
    #   {
    #     mode = ["n"];
    #     key = "<leader>F";
    #     action = "";
    #     options = {
    #       desc = "Format";
    #     };
    #   }
    # ];
  };
}
