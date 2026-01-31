{ inputs, lib, config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim # Vim text editor fork focused on extensibility and agility
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    configure = {
     # Base config came from https://github.com/nix-community/nixd/blob/main/nixd/docs/editors/nvim-lsp.nix
     customRC = ''
        lua <<EOF
        local g = vim.g
        local o = vim.opt

        -----------------------------------------------------------
        -- General
        -----------------------------------------------------------
        g.mapleader = " "
        g.maplocalleader = "\\"

        o.autowrite = true -- Enable auto write
        -- only set clipboard if not in ssh, to make sure the OSC 52
        -- integration works automatically. Requires Neovim >= 0.10.0
        o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
        o.swapfile = false -- Don't use swapfile
        o.completeopt = "menuone,noinsert,noselect" -- Autocomplete options
        g.autoformat = true

        -----------------------------------------------------------
        -- Neovim UI
        -----------------------------------------------------------
        o.completeopt = "menu,menuone,noselect"
        o.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
        o.confirm = true -- Confirm to save changes before exiting modified buffer
        o.cursorline = true -- Enable highlighting of the current line
        o.expandtab = true -- Use spaces instead of tabs
        o.fillchars = {
          foldopen = "",
          foldclose = "",
          fold = " ",
          foldsep = " ",
          diff = "╱",
          eob = " ",
        }
        o.foldlevel = 99
        o.formatoptions = "jcroqlnt" -- tcqj

        o.ignorecase = true -- Ignore case
        o.number = true -- Show line number

        o.relativenumber = true -- Relative line numbers
        o.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
        o.showmatch = true -- Highlight matching parenthesis
        o.foldmethod = "marker" -- Enable folding (default 'foldmarker')
        o.colorcolumn = "80" -- Line lenght marker at 80 columns
        o.splitright = true -- Vertical split to the right
        o.splitbelow = true -- Horizontal split to the bottom
        o.ignorecase = true -- Ignore case letters when search
        o.smartcase = true -- Ignore lowercase for the whole pattern
        o.smartindent = true -- Insert indents automatically
        o.linebreak = true -- Wrap on word boundary
        o.termguicolors = true -- Enable 24-bit RGB colors
        o.laststatus = 3 -- Set global statusline

        o.scrolloff = 4 -- Lines of context
        o.undofile = true
        o.undolevels = 10000

        o.updatetime = 200 -- Save swap file and trigger CursorHold
        o.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
        o.wildmode = "longest:full,full" -- Command-line completion mode
        o.wrap = false -- Disable line wrap
        o.foldmethod = "indent"

        -----------------------------------------------------------
        -- Tabs, indent
        -----------------------------------------------------------
        o.expandtab = true -- Use spaces instead of tabs
        o.shiftwidth = 4 -- Shift 4 spaces when tab
        o.tabstop = 8 -- 1 tab == 4 spaces
        o.smartindent = true -- Autoindent new lines

        -----------------------------------------------------------
        -- Memory, CPU
        -----------------------------------------------------------
        o.hidden = true -- Enable background buffers
        o.history = 100 -- Remember N lines in history
        o.synmaxcol = 240 -- Max column for syntax highlight
        o.updatetime = 250 -- ms to wait for trigger an event

        -----------------------------------------------------------
        -- Startup
        -----------------------------------------------------------
        -- Disable nvim intro
        o.shortmess:append("sI")

        -- Disable builtin plugins
        local disabled_built_ins = {
          "2html_plugin",
          "getscript",
          "getscriptPlugin",
          "gzip",
          "logipat",
          "netrw",
          "netrwPlugin",
          "netrwSettings",
          "netrwFileHandlers",
          "matchit",
          "tar",
          "tarPlugin",
          "rrhelper",
          "spellfile_plugin",
          "vimball",
          "vimballPlugin",
          "zip",
          "zipPlugin",
          "tutor",
          "rplugin",
          "synmenu",
          "optwin",
          "compiler",
          "bugreport",
          "ftplugin",
        }

        for _, plugin in pairs(disabled_built_ins) do
          g["loaded_" .. plugin] = 1
        end

        ----------------------------
        -- About gruvbox-material --
        ----------------------------
        vim.g.background = dark
        vim.g.gruvbox_material_enable_italic = true
        vim.g.gruvbox_material_background = 'hard'
        vim.g.gruvbox_material_better_performance = 1
        vim.cmd.colorscheme("gruvbox-material")

        -------------------------
        -- About mini-surround --
        -------------------------
        require('mini.surround').setup({
          mappings = {
            add = "gsa", -- Add surrounding in Normal and Visual modes
            delete = "gsd", -- Delete surrounding
            find = "gsf", -- Find surrounding (to the right)
            find_left = "gsF", -- Find surrounding (to the left)
            highlight = "gsh", -- Highlight surrounding
            replace = "gsr", -- Replace surrounding
            update_n_lines = "gsn", -- Update `n_lines`
          },
        })

        ----------------------
        -- About mini-pairs --
        ----------------------
        require('mini.pairs').setup()
      
        -----------------
        -- About noice --
        -----------------
        require("noice").setup({
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                            { find = "%d fewer lines" },
                            { find = "%d more lines" },
                        },
                    },
                    opts = { skip = true },
                },
            },
        })
      
        -------------------
        -- About lualine --
        -------------------
        require("lualine").setup({
            options = {
                theme = "auto",
                globalstatus = true,
            },
        })

        ------------------------
        -- About guess-indent --
        ------------------------
        require('guess-indent').setup {}
      
        ----------------------
        -- About treesitter --
        ----------------------
        require("nvim-treesitter.configs").setup({
        	highlight = {
        		enable = true,
        	},
        	indent = {
        		enable = true,
        	},
        })
      
        local function map(mode, lhs, rhs, opts)
          local options = { noremap = true, silent = true }
          if opts then
            options = vim.tbl_extend("force", options, opts)
          end
          vim.keymap.set(mode, lhs, rhs, options)
        end

        
        -- Fast saving with <leader> and w
        map("n", "<leader>w", ":w<CR>", { desc = "Save" })
        -- Fast saving all files with <leader> and W
        map("n", "<leader>W", ":wa<CR>", { desc = "Save All" })

        -- Close current buffer
        -- If this is the last buffer, return to the dashboard.
        map("n", "<leader>q", function()
            local num_listed_buffers = #vim.tbl_filter(function(bufnr)
                return vim.api.nvim_buf_get_option(bufnr, "buflisted")
            end, vim.api.nvim_list_bufs())
            if vim.bo.filetype ~= "snacks_dashboard"  then
                if num_listed_buffers > 0 then
                    require("snacks").bufdelete()
                end
                if num_listed_buffers <= 1 then
                    require("snacks").dashboard()
                end
            else
                vim.cmd("qa")
            end
        end, { desc = "Close Buffer" })

        -- Close all windows and exit from Neovim with <leader> and q
        map("n", "<leader>Q", ":qa<CR>", { desc = "Quit Nvim" })

        -- Make normal j and k presses work with wrapped words
        map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true})
        map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true})
        map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true})
        map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true})

        -- Clear search highlighting with escape
        map("n", "<esc>", "<CMD>nohlsearch<CR>")

        -- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
        map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
        map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
        map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
        map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
        map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
        map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

        -- Add undo break-points when writing non-code
        map("i", ",", ",<c-g>u")
        map("i", ".", ".<c-g>u")
        map("i", ";", ";<c-g>u")

        -- commenting
        map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
        map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

        EOF
      '';

      packages.all.start = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (ps: [ ps.nix ]))
        gruvbox-material
        guess-indent-nvim
        lualine-nvim
        mini-pairs
        mini-surround
        noice-nvim
        nvim-lspconfig
      ];
    };
  };


  environment.shellAliases = {
    e = "$EDITOR";
    edit = "$EDITOR";
    v = "nvim";
  };
}
