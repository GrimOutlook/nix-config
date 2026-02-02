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
      packages.all.start = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (ps: [ ps.nix ps.c-sharp ps.rust ]))
        actions-preview-nvim
        blink-cmp
        blink-cmp-conventional-commits
        blink-cmp-env
        blink-cmp-git
        blink-emoji-nvim
        blink-nerdfont-nvim
        conform-nvim
        diffview-nvim
        flash-nvim
        gitsigns-nvim
        grug-far-nvim
        gruvbox-material
        guess-indent-nvim
        lazy-nvim
        lualine-nvim
        marks-nvim
        mini-move
        mini-pairs
        mini-surround
        noice-nvim
        nvim-lspconfig
        oil-nvim
        overseer-nvim
        persistence-nvim
        project-nvim
        snacks-nvim
        tiny-inline-diagnostic-nvim
        todo-comments-nvim
        vim-suda
        which-key-nvim
      ];
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

        ------------------------------------
        -- Plugins with not configuration --
        ------------------------------------
        require('guess-indent').setup {}
        require('mini.pairs').setup()
        require('oil').setup()

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

        ------------------
        -- About snacks --
        ------------------
        require("snacks").setup({
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            explorer = { enabled = true },
            indent = { enabled = true },
            input = { enabled = true },
            picker = { enabled = true },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            rename = { enabled = true },
            scope = { enabled = true },
            scroll = { enabled = true },
            statuscolumn = { enabled = true },
            toggle = { enabled = true },
            words = { enabled = true },
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

        
        --------------------------------------------------------------------------------
        -- Plugin Keymaps --------------------------------------------------------------
        --------------------------------------------------------------------------------

        -- Diagnostics
        map("n", "D", function() vim.diagnostic.open_float() end, {desc = "Show Diagnostics"})

        -- Which-Key -------------------------------------------------------------------
        map("n", "<leader><leader>?", function() require("which-key").show({ global = false }) end, { desc = "[which-key] Buffer Local Keymaps" })

        -- -- Oil ----------------------------------------------------------------------
        map("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open oil file explorer" })


        -- Snacks Pickers --------------------------------------------------------------
        -- General
        map("n", "<leader>R", function() require("snacks").picker.resume() end, { desc = "Reopen Last Picker" })
        map("n", "<leader>ff", function() require("snacks").picker.files({ focus = "input" }) end, { desc = "Files" })
        map("n", "<leader>fr", function() require("snacks").picker.recent({ filter= { cwd = true }, current = false }) end, { desc = "Recent Files (CWD)" })
        map("n", "<leader>n", function() require("noice").cmd("last") end, { desc = "Last Notification" })
        map("n", "<leader>N", function() require("snacks").picker.notifications() end, { desc = "Notification History" })
        map("n", "<leader>b", function() require("snacks").picker.buffers({ current = false }) end, { desc = "Buffers" })

        -- Extras
        map("n", "<leader>si", function() require("snacks").picker.icons({focus = "input"}) end, { desc = "Icons" })
        map("n", "<leader>m", function() require("snacks").picker.marks() end, { desc = "Marks" })
        map("n", "<leader>sa", function() require("snacks").picker.autocmds() end, { desc = "Autocmds" })
        map("n", "<leader>sh", function() require("snacks").picker.help() end, { desc = "Help Pages" })
        map("n", "<leader>sk", function() require("snacks").picker.keymaps() end, { desc = "Keymaps" })
        map("n", "<leader>sc", function() require("snacks").picker.commands() end, { desc = "Commands" })
        map("n", "<leader>sC", function() require("snacks").picker.command_history() end, { desc = "Command History" })

        -- Text searching
        map("n", "<leader>//", function()
            require("snacks").picker.grep({
                focus = "input",
                dirs = {
                    vim.fn.expand("%")
                }

        }) end, { desc = "Search (Current File)" })
        map({ "v", "x" }, "<leader>/", function()
            require("snacks").picker.grep( {
                search = vim.fn.expand("<cword>"),
                dirs = {
                    vim.fn.expand("%")
                }
        }) end, { desc = "Search Selection (Current File)" })
        map("n", "<leader>/#", function()
            require("snacks").picker.grep( {
                search = vim.fn.expand("<cword>"),
                dirs = {
                    vim.fn.expand("%")
                }
        }) end, { desc = "Search Selection (Current File)" })
        map("n", "<leader>/r", function() require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } }) end, { desc = "Search and Replace (Current File)" })
        map({ "v", "x" }, "<leader>/r", function() require('grug-far').with_visual_selection({ prefills = { paths = vim.fn.expand("%") } }) end, { desc = "Search and Replace (Current File)" })
        map("n", "<leader>/?", function() require("snacks").picker.grep({focus="input"}) end, { desc = "Search (CWD)" })
        map({ "v", "x" }, "<leader>/?", function() require("snacks").picker.grep_word() end, { desc = "Search word (CWD)" })
        map("n", "<leader>/R", function() require("grug-far").open() end, { desc = "Search and Replace (CWD)" })
        map({ "v", "x" }, "<leader>/R", function() require('grug-far').open({ prefills = { search = vim.fn.expand("<cword>") } }) end, { desc = "Search and Replace (CWD)" })

        -- Issues
        map({ "n", "x" }, "<leader>a", function() require("actions-preview").code_action() end, { desc = "Code Actions" })
        map("n", "<leader>x", function() require("snacks").picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
        map("n", "<leader>X", function() require("snacks").picker.diagnostics() end, { desc = "Diagnostics" })

        -- LSP
        map("n", "gd", function() require("snacks").picker.lsp_definitions({ current = false })  end, { desc = "Goto Definition" })
        map("n", "gD", function() require("snacks").picker.lsp_declarations({ current = false })  end, { desc = "Goto Declaration" })
        map("n", "gr", function() require("snacks").picker.lsp_references({ current = false })  end, { nowait = true, desc = "References" })
        map("n", "gI", function() require("snacks").picker.lsp_implementations({ current = false })  end, { desc = "Goto Implementation" })
        map("n", "gy", function() require("snacks").picker.lsp_type_definitions({ current = false })  end, { desc = "Goto T[y]pe Definition" })
        map("n", "gai", function() require("snacks").picker.lsp_incoming_calls({ current = false })  end, { desc = "C[a]lls Incoming" })
        map("n", "gao", function() require("snacks").picker.lsp_outgoing_calls({ current = false })  end, { desc = "C[a]lls Outgoing" })

        -- Search
        map("n", "<leader>ss", function() require("snacks").picker.lsp_symbols({})  end, { desc = "LSP Symbols" })
        map("n", "<leader>sS", function() require("snacks").picker.lsp_workspace_symbols()  end, { desc = "LSP Workspace Symbols" })
        map("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix List" } )
        map("n", '<leader>s"', function() Snacks.picker.registers() end, {desc = "Registers" })
        map("n", '<leader>s/', function() Snacks.picker.search_history() end, {desc = "Search History" })
        map("n", '<leader>sj', function() Snacks.picker.jumps() end, {desc = "Jumps" })
        map("n", '<leader>sl', function() Snacks.picker.loclist() end, {desc = "Location List" })
        map("n", "<leader>st", function() Snacks.picker.todo_comments() end, {desc = "Search TODO, HACK, FIXME...", })
        -- TODO:
        -- map("n", "<leader>sr", function() require("utilities").openSearchAndReplace() end, {desc = "Search and Replace (WIP)", })

        -- Git
        map("n", "<leader>gf", function() require("snacks").picker.git_files() end, { desc = "Git Files" })
        map("n", "<leader>gl", function() require("snacks").picker.git_log() end, { desc = "Git Log" })

        map("n", "<leader>gb", function() Snacks.picker.git_branches() end, {desc = "Git Branches"} )
        map("n", "<leader>gl", function() Snacks.picker.git_log() end, {desc = "Git Log"} )
        map("n", "<leader>gL", function() Snacks.picker.git_log_line() end, {desc = "Git Log Line"} )
        map("n", "<leader>gs", function() Snacks.picker.git_status() end, {desc = "Git Status"} )
        map("n", "<leader>gS", function() Snacks.picker.git_stash() end, {desc = "Git Stash"} )
        map("n", "<leader>gd", function() Snacks.picker.git_diff() end, {desc = "Git Diff (Hunks)"} )
        map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, {desc = "Git Log File"} )

        -- gh
        map("n", "<leader>gi", function() Snacks.picker.gh_issue() end, {desc = "GitHub Issues (open)"} )
        map("n", "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, {desc = "GitHub Issues (all)"} )
        map("n", "<leader>gp", function() Snacks.picker.gh_pr() end, {desc = "GitHub Pull Requests (open)"} )
        map("n", "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, {desc = "GitHub Pull Requests (all)"} )

        -- Debuggers
        map("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Breakpoint Condition" })
        map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
        map("n", "<leader>dc", function() require("dap").continue() end, { desc = "Run/Continue" })
        map("n", "<leader>da", function() require("dap").continue({ before = get_args }) end, { desc = "Run with Args" })
        map("n", "<leader>dC", function() require("dap").run_to_cursor() end, { desc = "Run to Cursor" })
        map("n", "<leader>dg", function() require("dap").goto_() end, { desc = "Go to Line (No Execute)" })
        map("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step Into" })
        map("n", "<leader>dj", function() require("dap").down() end, { desc = "Down" })
        map("n", "<leader>dk", function() require("dap").up() end, { desc = "Up" })
        map("n", "<leader>dl", function() require("dap").run_last() end, { desc = "Run Last" })
        map("n", "<leader>do", function() require("dap").step_out() end, { desc = "Step Out" })
        map("n", "<leader>dO", function() require("dap").step_over() end, { desc = "Step Over" })
        map("n", "<leader>dP", function() require("dap").pause() end, { desc = "Pause" })
        map("n", "<leader>dr", function() require("dap").repl.toggle() end, { desc = "Toggle REPL" })
        map("n", "<leader>ds", function() require("dap").session() end, { desc = "Session" })
        map("n", "<leader>dt", function() require("dap").terminate() end, { desc = "Terminate" })
        map("n", "<leader>dw", function() require("dap.ui.widgets").hover() end, { desc = "Widgets" })

        -- Inc-rename
        vim.keymap.set("n", "cr", function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end, { desc = "Rename symbol", expr = true })

        -- Conform
        map({"n", "v", "x"}, "<leader>F", function()
          require("conform").format({ async = true }, function(err)
            if not err then
              local mode = vim.api.nvim_get_mode().mode
              if vim.startswith(string.lower(mode), "v") then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
              end
            end
          end)
        end, { desc = "Format code" })
        map({"n", "v", "x"}, "<leader><C-F>", function()
          local bufnr = 0
          local last_line_number = vim.api.nvim_buf_line_count(bufnr)
          local last_line = vim.api.nvim_buf_get_lines(bufnr, last_line_number - 1, last_line_number, true)
          local last_line_length = #last_line - 1
          require("conform").format({ async = true, range = { start = {1, 0}, ['end'] = {last_line_number, last_line_length} } })
        end, { desc = "Format Whole File" })

        -- Sort
        map ({"v", "x"}, "<leader>S", "<CMD>Sort<CR>", {desc = "Sort"})

        -- Overseer
        -- Pick and run task
        map ("n", "<leader>tq", "<CMD>OverseerRun<CR>", {desc = "Run Quick Task"})
        -- Run last task
        map("n", "<leader>tl", function()
          local overseer = require("overseer")
          local tasks = overseer.list_tasks({ recent_first = true })
          if vim.tbl_isempty(tasks) then
            vim.notify("No tasks found", vim.log.levels.WARN)
          else
            overseer.run_action(tasks[1], "restart")
          end
        end, { desc = "Run Last Task" })
        map ("n", "<leader>tu", "<CMD>OverseerToggle<CR>", {desc = "Toggle Overseer Tasks Window"})
        map ("n", "<leader>ts", "<CMD>OverseerShell<CR>", {desc = "Run Shell Command"})

        -- Toggles --------------------------------------------------------------------
        -- Toggle wrap
        map({"n", "i", "v", "x"}, "<leader>uw",
        function()
          vim.opt.wrap = not vim.opt.wrap:get()
          -- Optional: Provide feedback to the user
          if vim.opt.wrap:get() then
            print("Wrap enabled")
          else
            print("Wrap disabled")
          end
        end, { desc = "Toggle word wrap" })

        EOF
      '';

    };
  };


  environment.shellAliases = {
    e = "$EDITOR";
    edit = "$EDITOR";
    v = "nvim";
  };
}
