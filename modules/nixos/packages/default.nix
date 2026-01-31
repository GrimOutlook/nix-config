{ inputs, lib, config, pkgs, ... }:

{
    imports = [
        ./general/default.nix
        ./networking/default.nix
        ./nix.nix
        ./programming/default.nix
    ];
}
