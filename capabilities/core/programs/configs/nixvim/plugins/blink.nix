{
  config,
  lib,
  ...
}:
let
  cfg = config.host.default-programs.nixvim.plugins.blink;
in
{
  options.host.default-programs.nixvim.plugins.blink.enable =
    lib.mkEnableOption "Enable nixvim blink plugin";

  # NOTE: gate the whole `host.home-manager.config` definition, not the value
  # inside it. When nixvim is disabled its home-manager module is never
  # imported, so a `mkIf false` nested *under* `programs.nixvim` would still be
  # a definition of an option that does not exist, and evaluation fails.
  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim.plugins = {
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

          fuzzy.sorts = [
            "exact"
            "score"
            "sort_text"
          ];

          keymap.preset = "enter";
          signature.enabled = true;
          sources = {
            default = [
              "lsp"
              "path"
              "snippets"
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
            };
          };
        };
      };
    };
  };
}
