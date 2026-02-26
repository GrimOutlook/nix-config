{
  flake.modules.homeManager.dev.programs.nixvim =
    { pkgs, ... }:
    {
      plugins.snacks = {
        enable = true;
        settings.picker.enable = true;
      };

      keymaps = [
        {
          mode = "n";
          key = "gd";
          action = "<cmd>lua Snacks.picker.lsp_definitions({current = false})<cr>";
          options = {
            desc = "Goto Definintion";
          };
        }
        {
          mode = "n";
          key = "gD";
          action = "<cmd>lua Snacks.picker.lsp_declarations({current = false})<cr>";
          options = {
            desc = "Goto Declaration";
          };
        }
        {
          mode = "n";
          key = "gr";
          action = "<cmd>lua Snacks.picker.lsp_references({current = false})<cr>";
          options = {
            desc = "Goto References";
          };
        }
        {
          mode = "n";
          key = "gI";
          action = "<cmd>lua Snacks.picker.lsp_implementations({current = false})<cr>";
          options = {
            desc = "Goto Implementations";
          };
        }
        {
          mode = "n";
          key = "gy";
          action = "<cmd>lua Snacks.picker.lsp_type_definitions({current = false})<cr>";
          options = {
            desc = "Goto T[y]pe Definitions";
          };
        }
        {
          mode = "n";
          key = "D";
          action = "<cmd>lua vim.diagnostic.open_float()<cr>";
          options = {
            desc = "Show Diagnostic";
          };
        }
        {
          mode = "n";
          key = "<leader>x";
          action = "<cmd>lua require(\"snacks\").picker.diagnostics_buffer()<cr>";
          options = {
            desc = "Buffer Diagnostics";
          };
        }
        {
          mode = "n";
          key = "<leader>X";
          action = "<cmd>lua require(\"snacks\").picker.diagnostics()<cr>";
          options = {
            desc = "Diagnostics";
          };
        }
      ];
    };
}
