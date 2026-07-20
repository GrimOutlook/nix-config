# AGENTS.md

Quick orientation for agents working in `nix-config`. This repo holds shared
NixOS/home-manager modules consumed by every host in `nix-hosts` (and
`nix-homelab`) as a flake input (`nix-config`). It does not define any actual
machine — hosts pull it in and enable pieces of it via options.

## Structure — "dendritic" pattern

Based on github.com/GaetanLepage/nix-config. The flake root imports every
`default.nix` found under `flake/`, `capabilities/`, and `host-types/`
automatically via `inputs.import-tree` (see `flake.nix` and
`flake/modules.nix`) — there is no central list of modules to maintain.
Directory layout *is* the module tree: to add a module, add a file in the
right directory; to find where something is configured, look for its name as
a directory/file, not in an index.

```
.
├── flake.nix          -> inputs + calls flake-parts.lib.mkFlake over (import-tree ./flake)
├── flake/              -> flake-parts glue (not consumer-facing options)
├── capabilities/        -> reusable feature modules, grouped by domain
│   ├── core/            -> applied to every host regardless of type
│   ├── dev/              -> programming languages/tools
│   ├── graphical/        -> display manager, Hyprland, audio, etc.
│   ├── network-diag/     -> network diagnostic tooling
│   ├── virtualization/   -> virtualization/containers
│   └── misc/             -> small modules that don't fit elsewhere
└── host-types/          -> one module per machine class, each a bundle of
                             capabilities (desktop, laptop, pi, server, vm, wsl)
```

Each subdirectory that groups related modules has its own short `README.md`
(one-paragraph purpose statement) — check those first for orientation before
reading individual files.

## `flake/`

- `host.nix` — defines the `host.*` NixOS option namespace (`host.name`,
  `host.config`) that hosts use to register themselves.
- `modules.nix` — imports `capabilities/` + `host-types/` into
  `flake.modules.default` / `flake.nixosModules.default`. This is the actual
  wiring; if a capability doesn't seem to apply, check it's reachable from
  here.
- `systems.nix` — supported systems (`x86_64-linux`, `aarch64-linux`; no
  Darwin support).
- `devshell.nix` — devshell commands available via `nix develop`: `update`
  (flake update + commit + push), `switch` (rebuild/deploy current host via
  `nh os switch`), `unlink-results`.
- `deploy-rs.nix` — wires `deploy-rs` for remote deploys. **Currently broken**
  — see the `FIXME` comment in that file: `flake.deploy.nodes` depends on
  `config.host.hostname`/`config.networking.hostName`, neither of which is
  set at this level, so `deployChecks` is commented out.

## Capabilities

Toggled per-host via `host.<capability>.enable` (grep for `mkEnableOption` in
a capability's `default.nix` to find its exact option name — it isn't always
just the directory name). `capabilities/core/*` has no top-level toggle; it's
unconditionally applied to all hosts.

Notable non-obvious contents:
- `core/programs/` — a large curated set of CLI tools, split into `sets/*.nix`
  by category (searching, networking, compression, monitoring, ...) plus
  `configs/*` for tools that need dedicated config (atuin, starship, tmux,
  nixvim, etc.).
- `core/scripts/` — small custom shell scripts shipped as packages
  (`acronyms`, `certscrape`, `cs`, `macvendor`, `materialize`).
- `dev/lang/rust/` — this is a **scaffold/template**, not project config: it
  contains its own `AGENTS.md` with generic Rust-project conventions that get
  used *inside* newly created Rust projects, not this repo. Don't confuse it
  with this file.
- `dev/nixvim/` — Neovim config via nixvim; extra plugins not yet in the
  nixvim registry are declared as flake inputs in `flake.nix` (`karen-yank`,
  `smart-scrolloff`, `tiny-code-action`, `wayfinder`) and wired up in
  `plugins/`.
- `graphical/hyprpanel/` — ships a raw `config.json` alongside the module.

## Host types

Each host sets exactly one `host.type.<type>.enable = true`. Types are
additive bundles of capabilities, e.g. `desktop`/`laptop` enable
antivirus + bluetooth + bootloader + graphical; `server` enables antivirus +
bootloader + metrics + virtualization; `wsl`/`vm` pull in their respective
upstream modules (`nixos-wsl`, `microvm`) as flake inputs.

## Conventions / gotchas

- Prefer adding a new file under the right `capabilities/` or `host-types/`
  directory over editing `flake/modules.nix` — the import-tree wiring means
  new files are picked up automatically as long as they're `default.nix` (or
  otherwise reachable) under an existing directory.
- Options live under the `host.*` namespace almost everywhere — grep
  `host\.` in a capability file to find its option name before assuming a
  capability is unconditionally on.
- Some flake inputs (`agenix`, `deploy-rs`, `disko`, `microvm`,
  `nixos-wsl`, `stylix`, ...) are consumed only by specific capabilities /
  host-types, not globally — check where an input is actually referenced
  before assuming it applies to every host.
- A commented-out block in `git-hooks` inputs in `flake.nix` is intentional
  ("inherited... determine if I actually want these") — not dead code to
  clean up without asking.
- Two hosts in `nix-hosts` (`belfast`, `taipei`) still import
  `nix-config.modules.flake.host-info` and
  `(nix-config + "/flakes/systems.nix")` — neither exists in the current
  `flake/` layout (`flakes/` vs `flake/`, no `host-info` module). These
  flakes likely predate a restructure here and may not evaluate; worth
  flagging rather than silently "fixing" since the intended shape of
  `host-info` isn't obvious from this repo alone.
