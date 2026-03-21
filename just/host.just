set dotenv-load := true
set dotenv-required := true

NIX_REPO_HOST := env('NIX_REPO_HOST')
export NH_FLAKE := "github:GrimOutlook/nix-host-{{NIX_REPO_HOST}}"
DEFAULT_CONNECTION := 'root@' + NIX_REPO_HOST

# Build the nix configuration for this host
[group('build')]
build *args="":
  nh os build . -H {{NIX_REPO_HOST}} {{args}}

# Reconfigure both nixos and home-manager
[group('switch')]
switch *args="":
  nh os switch . -H {{NIX_REPO_HOST}} {{args}}

# Deploy this host flake for the first time to a new system
[group('deploy')]
deploy-new host=DEFAULT_CONNECTION *args="":
  just clear-ssh
  nix run github:nix-community/nixos-anywhere -- {{args}} \
    --flake .#{{NIX_REPO_HOST}} \
    {{host}}
  just switch --target-host {{host}} --build-host {{host}} {{args}}

# Deploy this host flake to a remote system
[group('deploy')]
deploy host=DEFAULT_CONNECTION *args="":
  just switch --target-host {{host}} --build-host {{host}} {{args}}
  just connect

# Connect to nix-host
[group('connect')]
connect host=DEFAULT_CONNECTION:
  ssh "{{host}}"

# Remove old `.known_hosts` entries for nix-host
[group('connect')]
[group('clean')]
clear-ssh host=DEFAULT_CONNECTION:
  ssh-keygen -R {{host}}
