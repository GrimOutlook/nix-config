{ inputs, lib, config, pkgs, ... }:

{
    imports = [
        ./general/default.nix
        # ./networking/default.nix
        ./programming/default.nix
    ];
}
