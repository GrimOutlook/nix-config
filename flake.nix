{
  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl.url = "github:nix-community/nixos-wsl";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Determine if I actually want these. They're cool but I just
    # inherited them from the initial flake I copied
    #
    # Seamless integration of git hooks with Nix
    # git-hooks = {
    #   url = "github:cachix/git-hooks.nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #
    # };
  };

  # Neovim plugins that aren't included in the `nixvim` standard yet.
  inputs = {
    # Neovim Lua plugin to improve register handling with delete, cut and yank
    # mappings.
    karen-yank-nvim = {
      flake = false;
      url = "github:tenxsoydev/karen-yank.nvim";
    };

    # NOTE: Dependency for `tiny-code-action-nvim`
    plenary-nvim = {
      flake = false;
      url = "github:nvim-lua/plenary.nvim";
    };

    # Smart scroll is a plugin that enables you to control the scrolloff
    # setting using percentages instead of static line numbers. This is a more
    # intuitive way to handle scrolling, especially as you move between
    # laptops, monitors, and resized windows and font sizes. Smart scrolloff
    # will always keep your scrolling experience consistent.
    smart-scrolloff-nvim = {
      flake = false;
      url = "github:tonymajestro/smart-scrolloff.nvim";
    };

    # A Neovim plugin that provides a simple way to run and visualize code
    # actions
    tiny-code-action-nvim = {
      flake = false;
      url = "github:rachartier/tiny-code-action.nvim";
    };

    # TODO: Determine if I actually want these. They're cool but I just
    # inherited them from the initial flake I copied
    #
    # # Jump to next/previous LSP reference in the current buffer for the item
    # # under the cursor with `]r`/`[r`.
    # refjump-nvim = {
    #   flake = false;
    #   url = "github:mawkler/refjump.nvim";
    # };
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
