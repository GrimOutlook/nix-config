{
  inputs = {
    self.submodules = true;
    
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Seamless integration of git hooks with Nix
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "dedupe_flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
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

    # Jump to next/previous LSP reference in the current buffer for the item
    # under the cursor with `]r`/`[r`.
    refjump-nvim = {
      flake = false;
      url = "github:mawkler/refjump.nvim";
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

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # TODO: Check if this is actually needed.
  # _additional_ `inputs` only for deduplication
  inputs = {
    dedupe_flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
