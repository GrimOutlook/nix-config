export NH_FLAKE := "github:GrimOutlook/nix-host-{{hostname}}"
DEFAULT_HOST := 'grim@' + hostname

alias us := update-switch
# Update flake.nix inputs and reconfigure system to new homeConfiguration
[group('switch')]
[group('update')]
update-switch: update home

alias switch := home

# Reconfigure system to new homeConfiguration
[group('switch')]
home *args:
  nh home switch . -c {{hostname}} {{args}}

# Reconfigure system to new nixosConfiguration
[group('switch')]
os:
  nh os switch . -H {{hostname}}

# Update flake.nix inputs
[group('update')]
update:
  nix flake update

# Check that config is valid
[group('check')]
check:
  nix flake check

# Check that config is valid using a local copy of `nix-config`
[group('check')]
[group('local')]
check-local PATH=nix-config-local:
  nix flake check --no-build --override-input nix-config path:{{PATH}}

# Reconfigure to a new config using a local copy of `nix-config`
[group('local')]
[group('switch')]
switch-local PATH=nix-config-local:
  just home -- --override-input nix-config path:{{PATH}}

# Deploy this host flake to a remote system
[group('deploy')]
deploy HOST=DEFAULT_HOST:
  nix run github:nix-community/nixos-anywhere -- --flake .#{{hostname}} {{HOST}} 
  just clear-ssh

# Deploy this host flake to a remote system for the first time
[group('deploy')]
deploy-new:
  just deploy "nixos@{{hostname}}"
  just clear-ssh

# Connect to nix-host
[group('connect')]
connect HOST=DEFAULT_HOST:
  ssh "{{HOST}}"

# Remove old `.known_hosts` entries for nix-host
[group('connect')]
[group('clean')]
clear-ssh:
  ssh-keygen -R {{hostname}}
