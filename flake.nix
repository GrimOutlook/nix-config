{
  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";

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
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    # Hardened kernel sources, used by `capabilities/core/hardening.nix`.
    # Tracked against upstream's per-minor-version branch (rather than a
    # release tag) so `nix flake update` alone picks up new hardened patch
    # releases for that kernel line -- bump the branch by hand when upstream
    # cuts a new minor version.
    linux-hardened = {
      url = "github:anthraxx/linux-hardened/7.1";
      flake = false;
    };

    # Hardened kernel for ZFS hosts, pinned to the newest hardened release
    # still on a kernel line that nixpkgs' `zfs`/`zfsUnstable` support
    # (`kernelMaxSupportedMajorMinor`, currently 7.0). Upstream's 7.0.x line
    # is EOL and no longer a rolling branch, so this tracks a tag rather than
    # a branch -- repin to a release on a newer line by hand once nixpkgs'
    # zfs raises its supported ceiling (capabilities/core/hardening.nix will
    # fail loudly via an assertion if this ever falls out of sync).
    linux-hardened-zfs = {
      url = "github:anthraxx/linux-hardened/v7.0.14-hardened1";
      flake = false;
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-wsl.url = "github:nix-community/nixos-wsl";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
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

    # A Neovim plugin that provides a simple way to run and visualize code
    # actions
    wayfinder-nvim = {
      flake = false;
      url = "github:error311/wayfinder.nvim";
    };
  };

  outputs =
    {
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./flake);
}
