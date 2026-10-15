# Public/private split evaluation

This branch makes `nix-config` the public configuration-code repository and
keeps `nix-homelab` as the private site/composition repository. It does not
require a new repository named `nix-site`.

## Public interface

- `nixosModules.default`: existing shared capabilities and host types.
- `nixosModules.host-<name>`: reviewed host profiles and standalone modules.
- `lib.mkHost`: assemble a system with the shared modules.
- `lib.mkHomelab`: inventory-to-network helpers. Every service port is declared
  explicitly in the site inventory; no port numbers are allocated automatically.
- `lib.mkFleetDeploy`: deployment machinery; node inventory is an argument.
- `services/frigate/default.nix`: module factory taking camera definitions,
  stream maps, addresses, ports, encrypted-secret paths and environment mappings.
- `services/home-assistant/default.nix`: module factory taking site configuration
  fragments, home settings, proxy addresses and local component source paths.
- `services/home-assistant/weather.nix`: weather fragment factory; coordinates,
  grid identifiers and contact information are required arguments.
- `capabilities/backup`: the current upstream backup-host capability, including
  rsync mirrors, Restic snapshots and completion notifications. Disk identifiers,
  source endpoints, authorized keys, schedules and ciphertext paths are private.

The public root has no private input. `nixosConfigurations.example` is a
synthetic system using documentation addresses and a locked login account:

Owner identity and monitoring hostnames have no placeholder defaults in the
reusable modules. Consumers supply these values where the corresponding features
are used; the synthetic example declares its own example identity explicitly.

Gotify is optional: hosts without `host.gotify.enable` need no notification URL
or token. Auditing, filesystem scrubbing and backups remain enabled independently;
their Gotify alert scripts and completion hooks are installed only when Gotify
is enabled. To opt in, set `host.gotify.enable = true`, `host.gotify.url` and
`host.gotify.secretFile` (an agenix-encrypted token). `host.gotify.tokenFile`
selects the runtime token path for the shared sender and ZFS integration.

```sh
nix eval --raw path:.#nixosConfigurations.example.config.system.build.toplevel.drvPath
```

Host profiles are not complete deployable systems: the private site supplies
hardware, actual inventory, secrets, and remaining site-specific service modules.

## Private composition

`nix-homelab/fleet.nix` assembles all ten hosts using one dependency graph.
It retains each host's output function so the Pi's vendor constructor and
installer, and Washington's package check, survive the consolidation.

Actual identity and common access keys are in `inventory.nix`. `site.nix`
supplies them to the public options and points secret integrations at private
ciphertext. Current upstream shared ciphertext was copied byte-for-byte into
`secrets/shared/`. The existing owner password hash was encrypted into
`secrets/owner-password.age`; it is not a plaintext Nix value.

Personal network/device inventory, hardware identifiers, camera files, household
automation fragments, switch snapshots and recipient lists remain private.
Modules with local assets or unresolved site coupling are retained there pending
further extraction. Modules moved into public host profiles are removed from
the private tree and its import lists; there are no empty migration placeholders.

## Evaluate unpublished changes

From the wrapper checkout:

```sh
just eval-host amsterdam
just eval-host dunkirk
just eval-fleet
```

The recipes use `path:` sources to include new untracked files and override the
private site's `nix-config` input with the adjacent checkout. They do not write
lockfiles, build systems, activate configurations, commit, or push.
Fleet evaluation runs one host per Nix process to keep memory use bounded.

From the private repository, `just build-host HOST` builds without activation.
The consolidated lockfile keeps a GitHub pin rather than an absolute local path;
the private input follows the published evaluation branch. Use the local
override when testing additional public changes before publishing them.

Consolidating also standardizes hosts on this checkout's shared nixpkgs pin.
That is a dependency change relative to independently pinned legacy hosts.
Washington follows the current upstream host's separate pinned nixpkgs for
Immich 3.2.2, rather than permitting the insecure 2.x package.

Upstream refreshes are fast-forwarded on the evaluation branches and adapted
into the split: moved modules remain public, while new site values and encrypted
credentials remain private. Disabled upstream modules (CryptPad on Washington
and Dubai's kiosk display) remain available but are not enabled by host profiles.
Deployment and secret decryption are not exercised by evaluation.

After the upstream refresh, all ten real host system derivations and the Pi
installer evaluate successfully. The public flake checks pass on both supported
architectures, and the built privacy-boundary check passes. Immich 3.2.2, backup
schedules, Home Assistant scenes and the enabled private HA MCP integration were
checked explicitly. All 37 existing service ports are preserved; MailFlow adds
the explicitly declared port 50006. Gitleaks reports no credentials in the
current public working tree.

## Publication and activation review

The original host repositories and their histories remain available for
comparison. No private Git history was imported into this public branch.
Existing public history still contains the previous identity, access-key
inventory and password hash; removing current files does not scrub that history.
Rotate the exposed password before treating this as a production migration.

Before activation, verify host encryption recipients against current host keys.
The new password ciphertext uses the recipient keys already recorded in this
checkout; evaluation cannot establish that those keys are current or that each
host can decrypt. The existing upstream ciphertext and recipient updates are
preserved in the private site, including the backup hosts' notification keys.

Gitleaks found no credentials in the current public working tree. The public
additions have also been checked for known household names, personal
domains, precise coordinates, actual MACs, SSH keys and disk serial paths. This
is not a full historical credential or personal-information audit.
