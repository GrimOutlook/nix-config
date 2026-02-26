{config, ...}:
{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        alejandra
        nix-tree
        nix-output-monitor
        statix
        patchelf

        # nixpkgs
        hydra-check
        nix-update
        nixpkgs-review
        nixfmt
        nixfmt-tree
        luarocks-packages-updater
        vimPluginsUpdater
      ];
    };
}
