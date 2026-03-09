set dotenv-load := true
set dotenv-required := true

NIX_REPO_HOST := env('NIX_REPO_HOST')
export NH_FLAKE := "github:GrimOutlook/nix-host-{{NIX_REPO_HOST}}"
DEFAULT_CONNECTION := 'root@' + NIX_REPO_HOST

# Reconfigure both nixos and home-manager
[group('switch')]
switch local-nix-config="" *args="":
  #!/usr/bin/env bash
  args="{{args}}"
  if [[ "{{ local-nix-config }}" != "" ]]; then
    args="$args --override-input nix-config path:{{local-nix-config}}"
  fi

  nh os switch . -H {{NIX_REPO_HOST}} {{args}}
# Deploy this host flake to a remote system
[group('deploy')]
deploy mode='' host=DEFAULT_CONNECTION local-nix-config="" *args="":
  #!/usr/bin/env bash
  args="{{args}}"
  if [[ "{{ local-nix-config }}" != "" ]]; then
    args="$args --override-input nix-config path:{{local-nix-config}}"
  fi

  if [[ "{{ mode }}" == "new" ]]; then
    just clear-ssh
    nix run github:nix-community/nixos-anywhere -- $args \
      --flake .#{{NIX_REPO_HOST}} \
      {{host}}
  else
    just switch --target-host {{host}} --build-host {{host}} $args
  fi
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
