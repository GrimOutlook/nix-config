{
  flake.modules.homeManager.dev.programs.nixvim = 
    {pkgs, ...}:
    {
      plugins = {
        grug-far.enable = true;
        snacks = {
          enable = true;
          settings.picker.enable = true;
        };
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>//";
          action = "<cmd>lua require(\"snacks\").picker.grep({ focus = \"input\", dirs = { vim.fn.expand(\"%\") } }<cr>";
          options = {
            desc = "Search (Current File)";
          };
        }
        {
          mode = "n";
          key = "<leader>/#";
          action = "<cmd>lua require(\"snacks\").picker.grep({ search = vim.fn.exand(\"<cword>\"), dirs = { vim.fn.expand(\"%\") } }<cr>";
          options = {
            desc = "Search Selection (Current File)";
          };
        }
        {
          mode = ["v" "x"];
          key = "<leader>/";
          action = "<cmd>lua require(\"snacks\").picker.grep({ search = vim.fn.exand(\"<cword>\"), dirs = { vim.fn.expand(\"%\") } }<cr>";
          options = {
            desc = "Search Selection (Current File)";
          };
        }
        {
          mode = "n";
          key = "<leader>/r";
          action = "<cmd>lua require(\"grug-far\").open({ prefills = { paths = vim.fn.expand(\"%\") } })<cr>";
          options = {
            desc = "Search and Replace (Current File)";
          };
        }
        {
          mode = ["v" "x"];
          key = "<leader>/r";
          action = "<cmd>lua require('grug-far').with_visual_selection({ prefills = { paths = vim.fn.expand(\"%\") } })<cr>";
          options = {
            desc = "Search and Replace (Current File)";
          };
        }
        {
          mode = "n";
          key = "<leader>/?";
          action = "<cmd>lua require(\"snacks\").picker.grep({focus=\"input\"})<cr>";
          options = {
            desc = "Search (CWD)";
          };
        }
        {
          mode = ["v" "x"];
          key = "<leader>/?";
          action = "<cmd>lua require(\"snacks\").picker.grep_word()<cr>";
          options = {
            desc = "Search Word (CWD)";
          };
        }
        {
          mode = "n";
          key = "<leader>/R";
          action = "<cmd>lua require(\"grug-far\").open()<cr>";
          options = {
            desc = "Search and Replace (CWD)";
          };
        }
        {
          mode = ["v" "x"];
          key = "<leader>/R";
          action = "<cmd>lua require(\"grug-far\").open({ prefills = { search = vim.fn.expand(\"<cword>\") } })<cr>";
          options = {
            desc = "Search and Replace (CWD)";
          };
        }
      ];
    };
}
