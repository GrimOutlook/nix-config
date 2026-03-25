# Update the given flake.nix inputs
[group('update')]
update FLAKE:
  nix flake update {{FLAKE}}

# Update nix-config input
[group('update')]
update-config:
  nix flake update nix-config

# Update all flake.nix inputs
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
