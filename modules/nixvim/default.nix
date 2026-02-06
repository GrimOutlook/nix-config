{ inputs, lib, config, pkgs, ... }:
{
  flake.modules.nixos.base = {
    imports = [
      # Include the nixvim modules
      inputs.nixvim.nixosModules.nixvim
    ];

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
        conform-nvim.enable = true;
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
        oil.enable = true;
        oil-git-status.enable = true;
        overseer.enable = true;
        package-info.enable = true;
        project-nvim.enable = true;
        refactoring.enable = true;
        render-markdown.enable = true;
        sleuth.enable = true;
        snacks.enable = true;
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
    };
  };
}
