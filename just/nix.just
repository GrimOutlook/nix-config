# Update flake.nix inputs
[group('update')]
update FLAKE:
  nix flake update {{FLAKE}}

[group('update')]
update-all:
  nix flake update

# Check that config is valid
[group('check')]
check:
  nix flake check

[group('git')]
commit-update:
  git commit -am "chore(nix): Update flake.lock"
