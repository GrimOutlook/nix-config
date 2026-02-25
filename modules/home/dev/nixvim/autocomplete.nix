{
  flake.modules.homeManager.dev.programs.nixvim =
    {lib, pkgs, ...}:
    {
      plugins= {
        blink-emoji.enable = true;
        blink-cmp = {
          enable = true;

          settings = {
            appearance.nerd_font_variant = "mono";
            completion = {
              documentation = {
                # Controls whether the documentation window will automatically show when selecting a completion item
                auto_show = true;
                # Delay before showing the documentation window
                auto_show_delay_ms = 500;
              };

              # Displays a preview of the selected item on the current line
              ghost_text.enabled = true;
            };
            fuzzy = {
              sorts = [
                "exact"
                "score"
                "sort_text"
              ];
            };
            keymap.preset = "enter";
            signature.enabled = true;
            sources = {
              default = [
                "lsp"
                "path"
                "snippets"
                "nerdfont"
                "emoji"
              ];

              providers = {
                lsp = {
                  name = "LSP";
                  module = "blink.cmp.sources.lsp";
                  score_offset = 1000;
                  min_keyword_length = 0;
                };
                snippets = {
                  name = "snippets";
                  module = "blink.cmp.sources.snippets";
                  min_keyword_length = 3;
                };
                # nerdfont = {
                #   module = "blink-nerdfont";
                #   name = "Nerd Fonts";
                #   score_offset = -12;
                #   opts = lib.nixvim.mkRaw ''
                #     insert = true -- Insert nerdfont icon (default) or complete its name
                #     ---@type string|table|fun():table
                #     trigger = function()
                #       return { ":" }
                #     end
                #   '';
                # };
                # emoji = {
                #   module = "blink-emoji";
                #   name = "Emoji";
                #   score_offset = -15;  
                #   opts = lib.nixvim.mkRaw ''
                #     insert = true -- Insert emoji (default) or complete its name
                #     ---@type string|table|fun():table
                #     trigger = function()
                #       return { ":" }
                #     end
                #   '';
                # };
              };
            };
          };
        };
      };
    };
}
