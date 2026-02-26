{
  flake.modules.homeManager.dev.programs.nixvim =
    { pkgs, ... }:
    {
      plugins = {
        tiny-inline-diagnostic = {
          enable = true;
          settings = {
            show_source = {
              enabled = true;
            };
            add_messages = {
              display_count = true;
            };
            multilines = {
              enabled = true;
            };
            virt_texts.priority = 10000;
          };
        };
      };
      extraConfigLua = ''
        -- Disable Neovim's default virtual text diagnostics
        vim.diagnostic.config({ virtual_text = false }) 
      '';
    };
}
