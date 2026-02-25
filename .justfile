export NH_FLAKE := "github:GrimOutlook/nix-config"

default:
  just --list

update:
  nix flake update

check:
  nix flake check
