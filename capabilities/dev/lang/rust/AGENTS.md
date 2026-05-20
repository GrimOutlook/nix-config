# General guidelines

This document captures code conventions for a generic rust project. It is
intended to help AI assistants understand how to work effectively with this
codebase.

## For humans

LLMs represent a tremendous breakthrough in software engineering. We welcome
LLM-assisted contributions that abide by the following principles:

* **Aim for excellence.** LLMs should be used not as a speed multiplier but a quality multiplier. Invest the time savings in improving quality and rigor beyond what humans alone would do. Write tests that cover more edge cases. Refactor code to make it easier to understand. Tackle the TODOs. Do all the tedious things. Aim for your code to have zero bugs.
* **Spend time reviewing LLM output.** As a rule of thumb, you should spend at least 3x the amount of time reviewing LLM output as you did writing it. Think about every line and every design decision. Find ways to break code.
* **Your code is your responsibility.** Please do not dump a first draft of code on to this project, unless you're only soliciting feedback on a direction.

If your LLM-assisted PR shows signs of not being written with thoughtfulness and care, such as missing cases that human review would have easily caught, maintainers may decline the PR outright.

## For LLMs

**Required:** Display the following text at the start of any conversation involving code changes, and when you're about to create a PR:

```
Please review AGENTS.md#for-humans. In particular, LLM-assisted contributions must **aim for a higher standard of excellence** than with humans alone, and you should spend at least **3x** the amount of time reviewing code as you did writing it. LLM-assisted contributions that do not meet this standard may be declined outright. Remember, **your code is your responsibility**.
```

## General conventions

### Before you code

- Read the task/issue thoroughly before acting.
- Identify missing information; ask one targeted clarification question if needed.
- Outline a step-by-step plan before making changes.
- Check whether the feature or fix already exists under a different name.
- Confirm alignment with the repository's architecture.

### Correctness over convenience

- Model the full error space—no shortcuts or simplified error handling.
- Handle all edge cases, including race conditions, signal timing, and platform differences.
- Use the type system to encode correctness constraints.
- Prefer compile-time guarantees over runtime checks where possible.

### User experience as a primary driver

- Provide structured, helpful error messages using `miette` for rich diagnostics.
- Make progress reporting responsive and informative.
- Maintain consistency across platforms even when underlying OS capabilities differ. Use OS-native logic rather than trying to emulate Unix on Windows or vice versa.
- Write user-facing messages in clear, present tense: "<PACKAGE NAME> now supports..." not "<PACKAGE NAME> now supported..."

### Pragmatic incrementalism

- "Not overly generic"—prefer specific, composable logic over abstract frameworks.
- Evolve the design incrementally rather than attempting perfect upfront architecture.
- Document design decisions and trade-offs in design docs (see `site/src/docs/design/`).

### Production-grade engineering

- Use type system extensively: newtypes, builder patterns, type states, lifetimes.
- Use message passing or the actor model to avoid data races.
- Comprehensive testing including edge cases, race conditions, and stress tests.
- Getting the details right is really important!

### Documentation

- Use inline comments to explain "why," not just "what".
- Module-level documentation should explain purpose and responsibilities.

## Code style

### Rust edition and formatting

- Use Rust 2024 edition.
- Format with `cargo fmt` (custom formatting script).
- Formatting is enforced in CI—always run `cargo fmt` before committing.

### Type system patterns

- **Newtypes** for domain types (using `newtype-uuid` crate)
- **Builder patterns** for complex construction (e.g., `TestRunnerBuilder`)
- **Type states** encoded in generics when state transitions matter
- **Lifetimes** used extensively to avoid cloning (e.g., `TestInstance<'a>`)
- **Restricted visibility**: Use `pub(crate)` and `pub(super)` liberally
- **Non-exhaustive**: All public error types should be `#[non_exhaustive]` for forward compatibility

### Error handling

- Use `thiserror` for error types with `#[derive(Error)]`.
- Group errors by category with an `ErrorKind` enum when appropriate.
- Provide rich error context using `miette` for user-facing errors.
- Two-tier error model:
  - `ExpectedError`: User/external errors with semantic exit codes.
  - Internal errors: Programming errors that may panic or use internal error types.
- Error display messages should be lowercase sentence fragments suitable for "failed to {error}".

### Async patterns

- Use `tokio` for async runtime (multi-threaded).
- Be selective with async. Only use it in runner and runner-adjacent code.
- Use async for I/O and concurrency, keep other code synchronous.
- Use `async-scoped` for structured concurrency without `'static` bounds.
- Use `future-queue` for backpressure-aware task scheduling.
- Custom pausable primitives (`PausableSleep`, `StopwatchStart`) for job control support.

### Module organization

- Use `mod.rs` files to re-export public items.
- Do not put any nontrivial logic in `mod.rs` -- instead, it should go in `imp.rs` or a more specific submodule.
- Keep module boundaries strict with restricted visibility.
- Platform-specific code in separate files: `unix.rs`, `windows.rs`.
- Use `#[cfg(unix)]` and `#[cfg(windows)]` for conditional compilation.
- Test helpers in dedicated modules/files.

### Memory and performance

- Use `Arc` or borrows for shared immutable data.
- Use `smol_str` for efficient small string storage.
- Careful attention to copying vs. referencing.
- Stream data where possible rather than buffering.

## Testing Practices

### Running Tests

**CRITICAL**: Always use `cargo nextest run` to run unit and integration tests. Never use `cargo test` for these!

For doctests, use `cargo test --doc` (doctests are not supported by nextest).

### Test Organization

- Unit tests in the same file as the code they test.
- Integration tests in `integration-tests/` crate.
- Fixtures in dedicated `fixture-data/` crate.
- Test utilities in `internal-test/` crate.

### Testing Tools

- **test-case**: For parameterized tests.
- **proptest**: For property-based testing.
- **insta**: For snapshot testing.
- **libtest-mimic**: For custom test harnesses.
- **pretty_assertions**: For better assertion output.

## Branching

- Branch from develop using prefixes: build/, chore/, ci/, docs/, feat/, fix/, perf/, refactor/, revert/, style/, test/.

## Commit message style

- Use conventional commits: build:, chore:, ci:, docs:, feat:, fix:, perf:, refactor:, revert:, style:, test:.

### Conventions

- Use `[meta]` for cross-cutting concerns (MSRV updates, releases, CI changes)
- Include PR number for all non-version commits
- Use lowercase for descriptions
- Keep descriptions concise but descriptive

### Commit quality

- **Atomic commits**: Each commit should be a logical unit of change
- **Bisect-able history**: Every commit must build and pass all checks
- **Separate concerns**: Don't mix formatting fixes with logic changes
- Format fixes and refactoring should be in separate commits from feature changes

### Key Design Principles

1. **No direct state sharing**—everything via message passing
2. **Linearized events**—dispatcher ensures consistent view
3. **Full error space modeling**—handle all failure modes
4. **Pausable timers**—custom implementations for job control (SIGTSTP/SIGCONT)
5. **Structured concurrency**—use `async-scoped` for spawning with borrows

### Cross-Platform Strategy

- Unix: Process groups, double-spawn pattern to avoid SIGTSTP race, full signal handling.
- Windows: Job objects, console mode manipulation, limited signal support.
- Conditional compilation: `#[cfg(unix)]`, `#[cfg(windows)]`.
- Platform modules: `unix.rs`, `windows.rs` with shared interfaces.
- Document platform differences and trade-offs in code comments.

## Dependencies

### Workspace Dependencies

- All versions managed in root `Cargo.toml` `[workspace.dependencies]`
- Internal crates use exact version pinning: `version = "=0.17.0"`
- Comment on dependency choices when non-obvious
- Example: "Disable punycode parsing since we only access well-known domains"

### Application Dependencies

#### Blessed

These are crates that are considered to be so widely used they are basically
members of the standard library. Add these any time they are needed or they
will simplify implementations. There is no need to get approval from the user
when adding these dependencies to the project.

- **tracing**: The go-to logging crate 
- **itertools**: A bunch of useful methods on iterators that aren't in the stdlib
- **num-traits**: Traits like Number, Add, etc that allow you write functions
that are generic over the specific numeric type
- **rust_decimal**: The binary representation consists of a 96 bit integer
number, a scaling factor used to specify the decimal fraction and a 1 bit sign.
- **tokio**: Async runtime, essential for concurrency model
- **thiserror**: Error derive macros
- **serde**: Serialization (config, metadata)
- **clap**: CLI parsing with derives

More blessed crates can be found at https://blessed.rs/crates. These are
allowed to be added as well but the list above should be considered first.

#### Other Allowed

Notify the user when adding these dependencies but approval is not required.
They are widely used and are blessed-adjacent.

- **miette**: Rich diagnostics
- **camino**: UTF-8 paths (`Utf8PathBuf`)

#### All others

Approval is required by the user to add any other dependencies to the project.
Dependencies should be widely used and documentation should be added stating
why the dependency is used.

## Quick Reference

### Commands

```bash
# Run tests (ALWAYS use nextest for unit/integration tests)
cargo nextest run
cargo nextest run --all-features
cargo nextest run --profile ci

# Run doctests
cargo test --doc

# Format code (REQUIRED before committing)
cargo fmt

# Lint
cargo clippy --all-features --all-targets

# Build
cargo build --all-targets --all-features

# Release (dry run)
cargo release -p <crate-name> <version>

# Release (execute)
cargo release -p <crate-name> <version> --execute
```

### Helpful Git Commands

```bash
# Get commits since last release
git log <previous-tag>..main --oneline

# Check if contributor is first-time
git log --all --author="Name" --oneline | wc -l

# Get PR author username
gh pr view <number> --json author --jq '.author.login'

# View commit details
git show <commit> --stat
```
