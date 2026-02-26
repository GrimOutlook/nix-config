{ inputs, ... }:
{
  flake.modules.homeManager.nixvim = {
    imports = [
      inputs.nixvim.homeModules.nixvim
    ];

    home.shellAliases.v = "nvim";

    programs.nixvim = {
      # TODO: Figure out why this is required here since it's already declared in
      # `configuration.nix`
      nixpkgs.config.allowUnfree = true;

      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      extraConfigLuaPre = builtins.readFile ./options.lua;

      # Enable the gruvbox colorscheme plugin
      colorschemes.gruvbox.enable = true;

      dependencies = {
        tree-sitter.enable = true;
      };

      lsp.servers = {
        # Typos
        typos.enable = true;
      };

      plugins = {
        # TODO: Maybe add `colorful-menu`?

        claude-code.enable = true;
        comment.enable = true;
        comment-box.enable = true;
        cursorline.enable = true;
        dressing.enable = true;
        flash.enable = true;
        flit.enable = true;
        friendly-snippets.enable = true;
        fugitive.enable = true;
        git-conflict.enable = true;
        gitblame.enable = true;
        gitsigns.enable = true;
        grug-far.enable = true;
        helpview.enable = true;
        highlight-colors.enable = true;
        illuminate.enable = true;
        lspconfig.enable = true;
        lspkind.enable = true;
        lualine.enable = true;
        luasnip.enable = true;
        marks.enable = true;
        mini-icons.enable = true;
        mini-move.enable = true;
        mini-pairs.enable = true;
        mini-surround.enable = true;
        navic.enable = true;
        neogen.enable = true;
        noice.enable = true;
        nvim-bqf.enable = true;
        nvim-lightbulb.enable = true;
        nvim-ufo.enable = true;
        overseer.enable = true;
        package-info.enable = true;
        persistence.enable = true;
        project-nvim.enable = true;
        refactoring.enable = true;
        render-markdown.enable = true;
        sleuth.enable = true;
        snacks = {
          enable = true;
          settings = {
            bigfile.enable = true;
            git.enable = true;
            indent.enable = true;
            input.enable = true;
            notifier.enable = true;
            quickfile.enable = true;
            rename.enable = true;
            scope.enable = true;
            scroll.enable = true;
            statuscolumn.enable = true;
            words.enable = true;
            styles.notifications.wo.wrap = true;
          };
        };
        spider.enable = true;
        tiny-inline-diagnostic.enable = true;
        tmux-navigator.enable = true;
        todo-comments.enable = true;
        toggleterm.enable = true;
        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };
        treesitter-context.enable = true;
        ts-comments.enable = true;
        ts-context-commentstring.enable = true;
        vim-suda.enable = true;
        web-devicons.enable = true;
        which-key.enable = true;
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>w";
          action = "<cmd>write<cr>";
          options = {
            desc = "Save";
          };
        }
        {
          mode = "n";
          key = "<leader>W";
          action = "<cmd>wall<cr>";
          options = {
            desc = "Save All";
          };
        }
        {
          mode = "n";
          key = "<leader>q";
          action.__raw = # lua
            ''
              function()
                if vim.bo.filetype == "snacks_dashboard"  then
                  vim.cmd("qa")
                end

                local num_listed_buffers = #vim.tbl_filter(function(bufnr)
                  return vim.api.nvim_buf_get_option(bufnr, "buflisted")
                end, vim.api.nvim_list_bufs())
                if num_listed_buffers <= 1 then
                  require("snacks").dashboard()
                else
                  require("snacks").bufdelete()
                end
              end
            '';
          options = {
            desc = "Close Buffer";
          };
        }
        {
          mode = "n";
          key = "<leader>Q";
          action = "<cmd>quitall<cr>";
          options = {
            desc = "Quit Nvim";
          };
        }

        # Clear search highlighting with escape
        {
          mode = "n";
          key = "<ESC>";
          action = "<cmd>nohlsearch<cr>";
          options = {
            desc = "Clear Search Highlighting";
          };
        }
      ];
    };
  };
}
