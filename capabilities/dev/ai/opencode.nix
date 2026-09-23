{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.opencode;
  reviewerEnabled = cfg.permissionReviewer.enable;
  render = (import ./_render.nix { inherit lib; }) config.host.dev.ai.shared;
  # Policy-aware permission reviewer plugin. Built from source rather than
  # pulled from npm: the published 1.3.1 predates the fixes we depend on, and
  # the pinned input is the integration branch that carries them (see the input
  # comment in flake.nix).
  #
  # Only `dist/` and `package.json` are installed. Everything the plugin needs
  # at runtime -- @opencode-ai/plugin, @opentui/*, solid-js -- is declared
  # `external` in its tsup config and supplied by the OpenCode host, so the
  # store path needs no node_modules. The dependencies below are build-time
  # only (tsup, typescript).
  permissionReviewerSrc = inputs.nix-config.inputs.opencode-permission-reviewer;
  permissionReviewerModules = pkgs.stdenv.mkDerivation {
    pname = "opencode-permission-reviewer-node-modules";
    version = "1.3.1";
    src = permissionReviewerSrc;

    nativeBuildInputs = [ pkgs.bun ];
    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME="$TMPDIR"
      bun install --frozen-lockfile --no-progress --ignore-scripts
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cp -R node_modules $out
      runHook postInstall
    '';

    # `bun install` writes store paths into node_modules (bun's own binary lands
    # in the .bin shims), and a fixed-output derivation may not reference the
    # store. The scan is what forbids it, not the paths themselves, so discard
    # the reference set -- the outer derivation rebuilds anything it needs.
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;

    # Fixed-output: `bun install` is the only step that needs the network.
    # Bump this hash whenever the pinned plugin revision changes its lockfile.
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-fnVOl24vROpKNT/zTlwZpk2C4Ha6SGliibv38gtXZJ8=";
  };
  permissionReviewer = pkgs.stdenv.mkDerivation {
    pname = "opencode-permission-reviewer";
    version = "1.3.1-integration";
    src = permissionReviewerSrc;

    # nodejs is not a runtime dependency of the plugin; patchShebangs needs it
    # on PATH to resolve the `#!/usr/bin/env node` lines below.
    nativeBuildInputs = [
      pkgs.bun
      pkgs.nodejs
    ];
    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME="$TMPDIR"
      cp -R ${permissionReviewerModules} node_modules
      chmod -R u+w node_modules

      # The sandbox has no /usr/bin/env, so the `#!/usr/bin/env node` shebangs
      # in the dependency CLIs (tsup) abort the build with "bad interpreter".
      # patchShebangs skips symlinks, and every node_modules/.bin entry is one,
      # so patch the real files they resolve to instead.
      for shim in node_modules/.bin/*; do
        target=$(readlink -f "$shim")
        if [ -f "$target" ]; then
          patchShebangs --build "$target"
        fi
      done

      bun run build
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R dist $out/dist
      cp package.json $out/package.json
      runHook postInstall
    '';

    # The overlay entry ships as raw TSX for the host to compile; a missing
    # dist/tui means the build silently dropped it.
    doInstallCheck = true;
    installCheckPhase = ''
      test -f $out/dist/index.js
      test -f $out/dist/tui/tui.tsx
    '';
  };
  # Keep these identical in opencode.json and tui.json: the server and the TUI
  # watchdog compare them, and a mismatch makes the overlay disagree with the
  # decision it is rendering.
  permissionReviewerPlugin = [
    "./plugins/opencode-permission-reviewer"
    {
      model = "openai/gpt-5.6-luna";
      variant = "max";
      timeoutMs = 120000;
    }
  ];

in
{
  options.host.dev.ai.opencode = {
    enable = lib.mkEnableOption "Enable OpenCode CLI configuration";

    permissionReviewer.enable =
      lib.mkEnableOption ''
        the policy-aware permission reviewer plugin, which sends every action
        the policy classifies as `ask` to a model for review instead of
        prompting immediately.

        Turning this off drops the plugin, its TUI overlay and its from-source
        build out of the closure. The `ask` verdicts in `permission.bash` stay
        exactly as they are and fall through to OpenCode's own interactive
        prompt
      ''
      // {
        default = true;
      };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = (pkgs.formats.json { }).type;
      };
      default = { };
      description = "Settings for OpenCode CLI written to ~/.config/opencode/opencode.json";
    };
  };

  config = lib.mkIf cfg.enable {
    host.dev.ai.opencode.settings = {
      "$schema" = "https://opencode.ai/config.json";
      disabled_providers = [ "opencode" ];
      share = "disabled";
      plugin = lib.mkIf reviewerEnabled [ permissionReviewerPlugin ];
      permission = {
        # With the reviewer on it only ever sees actions the policy classifies
        # as `ask`; with no ask rule it would be installed but inert. `bash` is
        # the surface it is built for -- the deterministic emergency brake runs
        # before any model call, and everything else goes to the reviewer. The
        # shared allowlist short-circuits the reviewer for routine commands; the
        # `*` catch-all in `render.opencode.bash` keeps every other command on
        # it. With the reviewer off these verdicts are unchanged; they just
        # become ordinary interactive prompts.
        bash = render.opencode.bash;
        external_directory = render.opencode.directories [
          "/tmp/opencode"
          # Allow access to Claude memory by default
          "~/.claude/projects"
        ];
      };
      references = {
        claude-projects = {
          path = "~/.claude/projects";
          description = "Claude Code auto-memory for all projects. Use only the memory for the current repository when relevant; start with MEMORY.md and read topic files only as needed.";
        };
      };
      mcp = {
        nixos = {
          enabled = true;
          type = "local";
          command = "nix run github:utensils/mcp-nixos --";
        };
      };
    };

    programs.fish.interactiveShellInit = ''
      complete -c opencode -f -a "(opencode --get-yargs-completions (commandline -opc) (commandline -ct) | string match -v '\$0')"
      complete -c opencode-commit -w opencode
    '';

    host.home-manager.config = {
      programs.fish.interactiveShellInit = ''
        complete -c opencode -f -a "(opencode --get-yargs-completions (commandline -opc) (commandline -ct) | string match -v '\$0')"
        complete -c opencode-commit -w opencode
      '';
      home = {
        # OpenCode's status dialog derives the display name from the plugin
        # path, so expose the store-built plugin through a stable basename.
        file.".config/opencode/plugins/opencode-permission-reviewer" = lib.mkIf reviewerEnabled {
          source = permissionReviewer;
        };
        file.".config/opencode/opencode.json" = {
          text = builtins.toJSON cfg.settings;
          force = true;
        };
        # The overlay is registered separately from the server plugin, with an
        # identical options block (see permissionReviewerPlugin).
        file.".config/opencode/tui.json" = {
          text = builtins.toJSON (
            {
              "$schema" = "https://opencode.ai/tui.json";
            }
            // lib.optionalAttrs reviewerEnabled {
              plugin = [ permissionReviewerPlugin ];
            }
          );
          force = true;
        };
        file.".config/opencode/plugins/tmux-notify.ts" = {
          text = ''
            import type { Plugin } from "@opencode-ai/plugin";

            export const TmuxNotify: Plugin = async ({ $ }) => {
              const reviewerStatusPrefix = "opencode-permission-reviewer.status.";
              // Keep this marker in sync with the reviewer's public metadata contract.
              const reviewerSessionMetadataKey = "opencode-permission-reviewer";
              let userInterrupted = false;
              const subagentSessions = new Set<string>();
              const reviewerSessions = new Set<string>();
              const targetPane = process.env.TMUX_PANE;

              const isReviewerSession = (info: {
                metadata?: Record<string, unknown>;
              }) => {
                const marker = info.metadata?.[reviewerSessionMetadataKey];
                if (typeof marker !== "object" || marker === null || Array.isArray(marker)) return false;
                const metadata = marker as { version?: unknown; kind?: unknown; requestID?: unknown };
                return (
                  metadata.version === 1 &&
                  metadata.kind === "permission-reviewer" &&
                  typeof metadata.requestID === "string"
                );
              };

              const decodeReviewerStatus = (command?: string) => {
                if (!command?.startsWith(reviewerStatusPrefix)) return;

                try {
                  const encoded = command.slice(reviewerStatusPrefix.length);
                  if (!encoded || encoded.length > 16_000) return;
                  const status = JSON.parse(
                    Buffer.from(encoded, "base64url").toString("utf8"),
                  ) as { version?: unknown; phase?: unknown; permission?: unknown; sessionID?: unknown };
                  const phase = status.phase === "manual" ? status.phase : undefined;
                  if (status.version !== 1 || phase === undefined || typeof status.sessionID !== "string") return;
                  return {
                    phase,
                    sessionID: status.sessionID,
                    permission: typeof status.permission === "string" ? status.permission : undefined,
                  };
                } catch {
                  return;
                }
              };

              const isTargetVisible = async () => {
                const result = await $`tmux display-message -p -t ''${targetPane} '#{pane_active} #{window_active_clients}'`
                  .quiet()
                  .nothrow();

                return result.exitCode === 0 && result.text().trim() === "1 1";
              };

              const showMessage = async (message: string) => {
                await $`tmux display-message -t ''${targetPane} ''${message}`.quiet().nothrow();
              };

              const showPopup = async (message: string) => {
                const encoded = Buffer.from(message, "utf8").toString("base64");
                const messageEnvironment = "OPENCODE_POPUP_B64=" + encoded;
                const targetEnvironment = "OPENCODE_TARGET_PANE=" + targetPane;
                const command = [
                  'printf "%s" "$OPENCODE_POPUP_B64" | base64 -d',
                  'printf "\\n\\nEnter: switch to OpenCode | Esc: close popup\\n"',
                  'escape=$(printf "\\033")',
                  'while IFS= read -r -s -n 1 key; do',
                  '  if [ "$key" = "$escape" ]; then',
                  '    exit',
                  '  elif [ -z "$key" ]; then',
                  '    tmux switch-client -t "$OPENCODE_TARGET_PANE"',
                  '    exit',
                  '  fi',
                  'done',
                ].join("\n");

                await $`tmux display-popup -E -t ''${targetPane} -T OpenCode -e ''${messageEnvironment} -e ''${targetEnvironment} sh -c ''${command}`
                  .quiet()
                  .nothrow();
              };

              return {
                event: async ({ event }) => {
                  if (!process.env.TMUX || !targetPane) return;

                  const type = event.type as string;
                  const properties = event.properties as {
                    command?: string;
                    permission?: string;
                    questions?: Array<{ header?: string }>;
                    sessionID?: string;
                    info?: {
                      id?: string;
                      parentID?: string;
                      metadata?: Record<string, unknown>;
                    };
                    status?: { type?: string };
                  };

                  if (type === "session.created" && properties.info?.id) {
                    if (isReviewerSession(properties.info)) {
                      reviewerSessions.add(properties.info.id);
                    } else if (properties.info.parentID) {
                      subagentSessions.add(properties.info.id);
                    }
                    return;
                  }

                  if (type === "session.deleted" && properties.info?.id) {
                    subagentSessions.delete(properties.info.id);
                    reviewerSessions.delete(properties.info.id);
                    return;
                  }

                  if (type === "tui.command.execute" && properties.command === "session.interrupt") {
                    userInterrupted = true;
                    return;
                  }

                  const reviewerStatus =
                    type === "tui.command.execute" ? decodeReviewerStatus(properties.command) : undefined;

                  if (type === "session.idle" && properties.sessionID) {
                    if (reviewerSessions.delete(properties.sessionID)) return;
                    if (subagentSessions.has(properties.sessionID)) return;

                    if (userInterrupted) {
                      userInterrupted = false;
                      return;
                    }
                  }

                  const message =
                    type === "session.idle"
                      ? "OpenCode: completed"
                      : reviewerStatus?.phase === "manual"
                        ? "OpenCode: permission needed (" + (reviewerStatus.permission ?? "approval") + ")"
                        : type === "question.asked"
                          ? "OpenCode: input needed (" + (properties.questions?.[0]?.header ?? "question") + ")"
                          : undefined;

                  if (!message) return;

                  if (await isTargetVisible()) {
                    if (type === "session.idle") await showMessage(message);
                    return;
                  }

                  await showPopup(message);
                },
              };
            };
          '';
          force = true;
        };
        packages = with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
          opencode
        ];
        shellAliases = {
          "opencode-commit" = "opencode run 'Commit the changes in this repo'";
        };
      };
    };
  };
}
