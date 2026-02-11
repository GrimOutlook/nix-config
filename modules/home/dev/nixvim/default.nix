{inputs, ...}:
{
  flake.modules.homeManager.dev = {
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
        blink-cmp.enable = true;
        blink-cmp-git.enable = true;
        blink-emoji.enable = true;
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
        project-nvim.enable = true;
        refactoring.enable = true;
        render-markdown.enable = true;
        sleuth.enable = true;
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
          action = "<cmd>writeall<cr>";
          options = {
            desc = "Save All";
          };
        }
        {
          mode = "n";
          key = "<leader>q";
          action = "<cmd>lua Snacks.bufdelete()<cr>";
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

        # Make normal j and k presses work with wrapped words
        {
          mode = ["n" "x"];
          key = "j";
          action = "v:count == 0 ? 'gj' : 'j'";
          options = {
            desc = "Down";
            expr = true;
          };
        }
        {
          mode = ["n" "x"];
          key = "<Down>";
          action = "v:count == 0 ? 'gj' : 'j'";
          options = {
            desc = "Down";
            expr = true;
          };
        }
        {
          mode = ["n" "x"];
          key = "k";
          action = "v:count == 0 ? 'gk' : 'k'";
          options = {
            desc = "Up";
            expr = true;
          };
        }
        {
          mode = ["n" "x"];
          key = "<Up>";
          action = "v:count == 0 ? 'gk' : 'k'";
          options = {
            desc = "Up";
            expr = true;
          };
        }
      ];
    };
  };
}
