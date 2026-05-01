{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  nc-inputs = inputs.nix-config.inputs;

  cfg = config.host.default-program.nixvim;
  mkRaw = nc-inputs.nixvim.lib.nixvim.mkRaw;

  # Custom plugins
  karen-yank = pkgs.vimUtils.buildVimPlugin {
    pname = "karen-yank-nvim";
    version = "unstable";
    src = nc-inputs.karen-yank-nvim;
  };

  smart-scrolloff = pkgs.vimUtils.buildVimPlugin {
    pname = "smart-scrolloff-nvim";
    version = "unstable";
    src = nc-inputs.smart-scrolloff-nvim;
  };
in
{

  options.host.default-program.nixvim.enable = lib.mkEnableOption "Enable Nixvim configuration";
  config.host = lib.mkIf cfg.enable {
    default-programs.nixvim.plugins.enable = true;
    home-manager.config = {
      imports = [
        nc-inputs.nixvim.homeModules.nixvim
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
          # Used to pixelate a PNG for display in Neovim
          chafa.enable = true;
        };

        lsp.servers = {
          # Typos
          typos.enable = true;
        };

        extraPlugins = [
          karen-yank
          smart-scrolloff
        ];

        extraConfigLua = ''
          require('karen-yank').setup({})
          require('smart-scrolloff').setup({})

          -- Disable Neovim's default virtual text diagnostics
          vim.diagnostic.config({ virtual_text = false })
        '';

        plugins = {
          # Formatting
          conform-nvim = {
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

              # NOTE: This is required to exist even if empty to prevent
              # `autoInstall.enable = true` from causing a nix build failure.
              formatters_by_ft = { };
            };
          };

          # Dashboard
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

              picker = {
                enable = true;
                focus = "list";
                win.preview.wo.wrap = true;
              };

              dashboard = {
                preset = {
                  keys = [
                    {
                      icon = " ";
                      key = "p";
                      desc = "Projects";
                      action = ":lua Snacks.dashboard.pick('projects')";
                    }
                    {
                      icon = " ";
                      key = "r";
                      desc = "Recent Files";
                      action = ":lua Snacks.picker.recent()";
                    }
                    {
                      icon = " ";
                      key = "f";
                      desc = "Find File";
                      action = ":lua Snacks.picker.files({ focus = 'input' })";
                    }
                    {
                      icon = " ";
                      key = "/";
                      desc = "Find Text";
                      action = ":lua Snacks.picker.grep({focus='input'})";
                    }
                    {
                      icon = " ";
                      key = "s";
                      desc = "Find and Replace Text";
                      action = ":lua require('grug-far').open() end";
                    }
                    {
                      icon = "󱞋 ";
                      key = "e";
                      desc = "File Explorer (Fyler)";
                      action = "<CMD>Fyler<CR>";
                    }
                    {
                      icon = " ";
                      key = "g";
                      desc = "Git (Diff)";
                      action = ":lua Snacks.dashboard.pick({ 'git_diff' })";
                    }
                    {
                      icon = "󰀦 ";
                      key = "n";
                      desc = "Notifications";
                      action = ":lua Snacks.dashboard.pick('notification')";
                    }
                    {
                      icon = " ";
                      key = "c";
                      desc = "Config";
                      action = ":lua Snacks.dashboard.pick('files'; {cwd = vim.fn.stdpath('config')})";
                    }
                    {
                      icon = " ";
                      key = "z";
                      desc = "Restore Session";
                      action = ":lua require('persistence').load({ last = true })";
                    }
                    {
                      icon = " ";
                      key = "q";
                      desc = "Quit";
                      action = ":qa";
                    }
                  ];
                  header = ''
                                )  (    (      (    (      (     (        )
                      *   )  ( /(  )\ ) )\ )   )\ ) )\ )   )\ )  )\ )  ( /(
                    ` )  /(  )\())(()/((()/(  (()/((()/(  (()/( (()/(  )\()) (
                     ( )(_))((_)\  /(_))/(_))  /(_))/(_))  /(_)) /(_))((_)\  )\
                    (_(_())  _((_)(_)) (_))   (_)) (_))   (_))_|(_))   _((_)((_)
                    |_   _| | || ||_ _|/ __|  |_ _|/ __|  | |_  |_ _| | \| || __|
                      | |   | __ | | | \__ \   | | \__ \  | __|  | |  | .` || _|
                      |_|   |_||_||___||___/  |___||___/  |_|   |___| |_|\_||___|
                  '';
                };
                sections = [
                  {
                    section = "terminal";
                    cmd = "${pkgs.uutils-coreutils-noprefix}/bin/cat ${./features/dashboard/thisisfine.txt}; sleep 0.1";
                    padding = 1;
                    height = 30;
                  }
                  {
                    section = "header";
                    pane = 2;
                  }
                  {
                    pane = 2;
                    section = "keys";
                    gap = 1;
                    padding = 1;
                  }
                ];
              };
            };
          };

          # Other plugins
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
          gitblame = {
            enable = true;
            settings = {
              set_extmark_options = {
                priority = 100;
              };
            };
          };
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
          persistence.enable = true;
          project-nvim.enable = true;
          refactoring.enable = true;
          render-markdown.enable = true;
          sleuth.enable = true;
          spider.enable = true;
          tiny-inline-diagnostic = {
            enable = true;
            settings = {
              show_source.enabled = true;
              add_messages.display_count = true;
              multilines.enabled = true;
              virt_texts.priority = 10000;
            };
          };
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
          treesitter-context = {
            enable = true;
            settings = {
              # Tired of context taking up half my screen
              max_lines = 3;
              # Fix only outer scope being shown
              trim_scope = "inner";
            };
          };
          ts-comments.enable = true;
          ts-context-commentstring.enable = true;
          vim-suda.enable = true;
          web-devicons.enable = true;
          which-key = {
            enable = true;
            settings = {
              preset = "helix";
              delay = 200;
              expand = 1;
              notify = false;
            };
          };

        };

        keymaps = [
          # Basic keymaps
          {
            mode = "n";
            key = "<leader>w";
            action = "<cmd>write<cr>";
            options.desc = "Save";
          }
          {
            mode = "n";
            key = "<leader>W";
            action = "<cmd>wall<cr>";
            options.desc = "Save All";
          }
          {
            mode = "n";
            key = "<leader>q";
            action = mkRaw ''
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
            options.desc = "Close Buffer";
          }
          {
            mode = "n";
            key = "<leader>Q";
            action = "<cmd>quitall<cr>";
            options.desc = "Quit Nvim";
          }

          # Clear search highlighting with escape
          {
            mode = "n";
            key = "<ESC>";
            action = "<cmd>nohlsearch<cr>";
            options.desc = "Clear Search Highlighting";
          }

          # Formatting keymap
          {
            mode = [ "n" ];
            key = "<leader>F";
            action = "<CMD>lua require('conform').format()<CR>";
            options.desc = "Format File";
          }

          # LSP keymaps
          {
            mode = "n";
            key = "<leader>cd";
            action = "<cmd>lua Snacks.picker.lsp_definitions({current = false})<cr>";
            options.desc = "Goto Definintion";
          }
          {
            mode = "n";
            key = "<leader>cD";
            action = "<cmd>lua Snacks.picker.lsp_declarations({current = false})<cr>";
            options.desc = "Goto Declaration";
          }
          {
            mode = "n";
            key = "<leader>cr";
            action = "<cmd>lua Snacks.picker.lsp_references({current = false})<cr>";
            options.desc = "Goto References";
          }
          {
            mode = "n";
            key = "<leader>ci";
            action = "<cmd>lua Snacks.picker.lsp_implementations({current = false})<cr>";
            options.desc = "Goto Implementations";
          }
          {
            mode = "n";
            key = "<leader>cy";
            action = "<cmd>lua Snacks.picker.lsp_type_definitions({current = false})<cr>";
            options.desc = "Goto T[y]pe Definitions";
          }
          {
            mode = "n";
            key = "D";
            action = "<cmd>lua vim.diagnostic.open_float()<cr>";
            options.desc = "Show Diagnostic";
          }
          {
            mode = "n";
            key = "<leader>x";
            action = ''<cmd>lua require("snacks").picker.diagnostics_buffer()<cr>'';
            options.desc = "Buffer Diagnostics";
          }
          {
            mode = "n";
            key = "<leader>X";
            action = ''<cmd>lua require("snacks").picker.diagnostics()<cr>'';
            options.desc = "Diagnostics";
          }

          # Picker keymaps
          {
            mode = "n";
            key = "<leader>b";
            action = "<cmd>lua Snacks.picker.buffers({current = false})<cr>";
            options.desc = "Find buffers";
          }
          {
            mode = "n";
            key = "<leader>R";
            action = "<cmd>lua Snacks.picker.resume()<cr>";
            options.desc = "Reopen Last Picker";
          }
          {
            mode = "n";
            key = "<leader>ff";
            action = "<cmd>lua Snacks.picker.files({current = false})<cr>";
            options.desc = "Files";
          }
          {
            mode = "n";
            key = "<leader>fr";
            action = "<cmd>lua Snacks.picker.recent({ filter= { cwd = true }, current = false })<cr>";
            options.desc = "Recent Files (CWD)";
          }

          # Search keymaps
          {
            mode = "n";
            key = "<leader>//";
            action = ''<cmd>lua require("snacks").picker.grep({ focus = "input", dirs = { vim.fn.expand("%") } }<cr>'';
            options.desc = "Search (Current File)";
          }
          {
            mode = "n";
            key = "<leader>/#";
            action = ''<cmd>lua require("snacks").picker.grep({ search = vim.fn.exand("<cword>"), dirs = { vim.fn.expand("%") } }<cr>'';
            options.desc = "Search Selection (Current File)";
          }
          {
            mode = [
              "v"
              "x"
            ];
            key = "<leader>/";
            action = ''<cmd>lua require("snacks").picker.grep({ search = vim.fn.exand("<cword>"), dirs = { vim.fn.expand("%") } }<cr>'';
            options.desc = "Search Selection (Current File)";
          }
          {
            mode = "n";
            key = "<leader>/r";
            action = ''<cmd>lua require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })<cr>'';
            options.desc = "Search and Replace (Current File)";
          }
          {
            mode = [
              "v"
              "x"
            ];
            key = "<leader>/r";
            action = ''<cmd>lua require('grug-far').with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })<cr>'';
            options.desc = "Search and Replace (Current File)";
          }
          {
            mode = "n";
            key = "<leader>/?";
            action = ''<cmd>lua require("snacks").picker.grep({focus="input"})<cr>'';
            options.desc = "Search (CWD)";
          }
          {
            mode = [
              "v"
              "x"
            ];
            key = "<leader>/?";
            action = ''<cmd>lua require("snacks").picker.grep_word()<cr>'';
            options.desc = "Search Word (CWD)";
          }
          {
            mode = "n";
            key = "<leader>/R";
            action = ''<cmd>lua require("grug-far").open()<cr>'';
            options.desc = "Search and Replace (CWD)";
          }
          {
            mode = [
              "v"
              "x"
            ];
            key = "<leader>/R";
            action = ''<cmd>lua require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })<cr>'';
            options.desc = "Search and Replace (CWD)";
          }

          # Wrapped word motions
          {
            mode = [
              "n"
              "x"
            ];
            key = "j";
            action = "v:count == 0 ? 'gj' : 'j'";
            options = {
              desc = "Down";
              expr = true;
            };
          }
          {
            mode = [
              "n"
              "x"
            ];
            key = "<Down>";
            action = "v:count == 0 ? 'gj' : 'j'";
            options = {
              desc = "Down";
              expr = true;
            };
          }
          {
            mode = [
              "n"
              "x"
            ];
            key = "k";
            action = "v:count == 0 ? 'gk' : 'k'";
            options = {
              desc = "Up";
              expr = true;
            };
          }
          {
            mode = [
              "n"
              "x"
            ];
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
  };
}
