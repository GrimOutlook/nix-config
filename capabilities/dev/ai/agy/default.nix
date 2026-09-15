{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.agy;
  render = (import ../_render.nix { inherit lib; }) config.host.dev.ai.shared;
  # A function of the home directory: this config is applied to every
  # home-manager user, and the statusline script lives in each user's own home.
  agySettings = homeDirectory: {
    allowNonWorkspaceAccess = true;
    colorScheme = "dark";
    enableTelemetry = false;
    statusLine = {
      enabled = true;
      type = "command";
      command = "${homeDirectory}/.gemini/antigravity-cli/statusline.sh";
    };
    ui = {
      showTokenUsage = true;
    };
    permissions = {
      allow = render.agy.directories [ "/tmp/antigravity" ] ++ render.agy.commands;
      deny = render.agy.deniedCommands;
    };
  };
  agyKeybindings =
    # Example: Unbind ctrl-k from its default action
    {
      # Unbind default
      "-agent.action.approve" = [
        "ctrl+k"
      ];

      # Example: Rebind to ctrl-y
      "agent.action.approve" = [
        "ctrl+y"
      ];
      "subagent.approve_fast" = [
        "ctrl+y"
      ];
    };
in
{
  options.host.dev.ai.agy.enable = lib.mkEnableOption "Enable Antigravity CLI (agy) configuration";

  config = lib.mkIf cfg.enable {
    host.home-manager.config =
      { config, ... }:
      let
        settings = agySettings config.home.homeDirectory;
      in
      {
        home = {
          file = {
            ".gemini/antigravity-cli/settings.json" = {
              text = builtins.toJSON settings;
              force = true;
            };
            ".gemini/antigravity-cli/keybindings.json" = {
              text = builtins.toJSON agyKeybindings;
              force = true;
            };
            ".gemini/config/settings.json" = {
              text = builtins.toJSON settings;
              force = true;
            };
            ".gemini/config/keybindings.json" = {
              text = builtins.toJSON agyKeybindings;
              force = true;
            };
            ".gemini/antigravity-cli/statusline.sh" = {
              source = ./statusline.sh;
              executable = true;
            };
          };
          packages = with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
            antigravity-cli
          ];
          shellAliases = {
            "agy-commit" = "agy -p 'Commit the changes in this repo'";
          };
        };
      };
  };
}
