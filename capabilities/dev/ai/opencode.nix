{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.host.dev.ai.opencode;
in {
  options.host.dev.ai.opencode = {
    enable = lib.mkEnableOption "Enable OpenCode CLI configuration";

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = (pkgs.formats.json {}).type;
      };
      default = {};
      description = "Settings for OpenCode CLI written to ~/.config/opencode/opencode.json";
    };
  };

  config = lib.mkIf cfg.enable {
    host.dev.ai.opencode.settings = {
      "$schema" = "https://opencode.ai/config.json";
      disabled_providers = ["opencode"];
      share = "disabled";
      permission = {
        external_directory = {
          "/tmp/opencode/**" = "allow";
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

              const showPopup = async (message: string) => {
                const encoded = Buffer.from(message, "utf8").toString("base64");
                const environment = "OPENCODE_POPUP_B64=" + encoded;
                const command = 'printf "%s" "$OPENCODE_POPUP_B64" | base64 -d; printf "\\n"';

                await $`tmux display-popup -t ''${targetPane} -T OpenCode -e ''${environment} sh -c ''${command}`
                  .quiet()
                  .nothrow();

                await $`tmux switch-client -t ''${targetPane}`.quiet().nothrow();
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

                  if (message) await showPopup(message);
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
