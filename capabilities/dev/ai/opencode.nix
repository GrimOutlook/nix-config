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
  githubMcpLauncher = pkgs.writeShellScript "github-mcp" ''
    set -eu
    GITHUB_PERSONAL_ACCESS_TOKEN="$(${pkgs.gh}/bin/gh auth token --hostname github.com)"
    export GITHUB_PERSONAL_ACCESS_TOKEN
    exec ${pkgs.github-mcp-server}/bin/github-mcp-server stdio "$@"
  '';
  haMcpLauncher = pkgs.writeShellScript "ha-mcp" ''
    set -eu
    set -a
    . ${lib.escapeShellArg config.age.secrets.ha-mcp-env.path}
    set +a
    exec ${pkgs.uv}/bin/uvx ha-mcp "$@"
  '';
  # Build once for both host integrations from the fleet's locked source.
  permissionReviewer = import ./_permission-reviewer.nix { inherit inputs pkgs; };
  # Keep these identical in opencode.json and tui.json: the server and the TUI
  # watchdog compare them, and a mismatch makes the overlay disagree with the
  # decision it is rendering.
  permissionReviewerPlugin = [
    "./plugins/opencode-permission-reviewer"
    {
      mode = cfg.permissionReviewer.mode;
      model = "openai/gpt-6.1-sol";
      variant = "low";
      timeoutMs = 60000;
      maxEnrichmentChars = 400000;
    }
  ];

in
{
  options.host.dev.ai.opencode = {
    enable = lib.mkEnableOption "Enable OpenCode CLI configuration";

    haMcp = {
      enable = lib.mkEnableOption "the site-specific Home Assistant MCP integration";
      secretFile = lib.mkOption {
        type = lib.types.path;
        description = "Encrypted Home Assistant MCP environment supplied by the private site.";
      };
    };

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

    permissionReviewer.mode = lib.mkOption {
      type = lib.types.enum [
        "automatic"
        "human-review"
      ];
      default = "automatic";
      description = ''
        Automatic review allows or denies every reviewed request, returning the
        denial reason to the agent so it can correct itself. Human-review mode
        leaves questionable requests pending for a human to decide.
      '';
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
    age.secrets.ha-mcp-env = lib.mkIf cfg.haMcp.enable {
      file = cfg.haMcp.secretFile;
      owner = config.host.owner.username;
      group = config.users.users.${config.host.owner.username}.group;
      mode = "0400";
    };

    host.dev.ai.opencode.settings = {
      "$schema" = "https://opencode.ai/config.json";
      model = "openai/gpt-6.1-sol";
      agent = {
        build = {
          model = "openai/gpt-6.1-sol";
          variant = "low";
        };
        plan = {
          model = "openai/gpt-6.1-sol";
          variant = "low";
        };
      };
      disabled_providers = [ "gitlab" ];
      share = "disabled";
      # GLM-5.3 is served through Mistral's OpenAI-compatible API. Its streamed
      # tool-call deltas are spec-compliant -- `id` and `name` arrive on the
      # first delta and continuation deltas are matched by `index` with a null
      # id -- but opencode's default @ai-sdk/mistral parser rejects those id-less
      # continuations with AI_TypeValidationError (delta.tool_calls.0.id:
      # expected string, received undefined). @ai-sdk/openai-compatible matches
      # tool-call fragments by index and tolerates the null id, so override just
      # the SDK package for the mistral provider. The provider id stays
      # `mistral`, so the existing API key and model selection are unaffected.
      provider = {
        mistral = {
          npm = "@ai-sdk/openai-compatible";
          options.baseURL = "https://api.mistral.ai/v1";
        };
      };
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
        context7 = {
          enabled = true;
          type = "remote";
          url = "https://mcp.context7.com/mcp";
        };
        github = {
          enabled = true;
          type = "local";
          command = [ "${githubMcpLauncher}" ];
        };
        # Load credentials only in the MCP process, from the owner's secret.
        ha-mcp = lib.mkIf cfg.haMcp.enable {
          enabled = true;
          type = "local";
          command = [ "${haMcpLauncher}" ];
        };
        nixos = {
          enabled = true;
          type = "local";
          command = [
            "nix"
            "run"
            "github:utensils/mcp-nixos"
            "--"
          ];
        };
        playwright = {
          enabled = true;
          type = "local";
          command = [
            "${pkgs.playwright-mcp}/bin/playwright-mcp"
            "--headless"
            "--isolated"
          ];
        };
      };
    };

    programs.fish.interactiveShellInit = ''
      complete -c opencode -f -a "(opencode --get-yargs-completions (commandline -opc) (commandline -ct) | string match -v '\$0')"
      complete -c opencode-commit -w opencode
    '';

    host.home-manager.config = { config, ... }: {
      programs.fish.interactiveShellInit = ''
        complete -c opencode -f -a "(opencode --get-yargs-completions (commandline -opc) (commandline -ct) | string match -v '\$0')"
        complete -c opencode-commit -w opencode
      '';
      home = {
        file.".config/opencode/permission-reviewer.jsonc" = lib.mkIf reviewerEnabled {
          text = builtins.toJSON {
            scriptReadRoots = [
              "${config.home.homeDirectory}/.gsd-path/runtimes"
            ];
          };
        };
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
