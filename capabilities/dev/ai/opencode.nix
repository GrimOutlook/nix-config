{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.opencode;
in
{
  options.host.dev.ai.opencode = {
    enable = lib.mkEnableOption "Enable OpenCode CLI configuration";

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
      permission = {
        external_directory = {
          "/tmp/opencode/**" = "allow";
          # Allow access to Claude memory by default
          "~/.claude/projects/**" = "allow";
        };
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
        file.".config/opencode/opencode.json" = {
          text = builtins.toJSON cfg.settings;
          force = true;
        };
        file.".config/opencode/plugins/tmux-notify.ts" = {
          text = ''
            import type { Plugin } from "@opencode-ai/plugin";

            export const TmuxNotify: Plugin = async ({ $ }) => {
              let userInterrupted = false;
              const targetPane = process.env.TMUX_PANE;

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
                  'printf "\\n"',
                  'while IFS= read -r -s -n 1 key; do',
                  '  if [ -z "$key" ]; then',
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
                  };

                  if (type === "tui.command.execute" && properties.command === "session.interrupt") {
                    userInterrupted = true;
                    return;
                  }

                  if (type === "session.idle" && userInterrupted) {
                    userInterrupted = false;
                    return;
                  }

                  const message =
                    type === "session.idle"
                      ? "OpenCode: completed"
                      : type === "permission.asked"
                        ? "OpenCode: permission needed (" + (properties.permission ?? "approval") + ")"
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
