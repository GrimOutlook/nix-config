{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.claude;
in
{
  options.host.dev.ai.claude.enable = lib.mkEnableOption "Enable Claude Code CLI configuration";

  config = lib.mkIf cfg.enable {
    # Policy-tier settings: takes precedence over ~/.claude/settings.json, which is
    # left unmanaged so `/model` and `/config` can still write to it.
    environment.etc = {
      "claude-code/statusline.sh" = {
        source = ./statusline.sh;
        mode = "0755";
      };

      "claude-code/managed-settings.json".text = builtins.toJSON {
        statusLine = {
          type = "command";
          command = "/etc/claude-code/statusline.sh";
        };
        permissions.defaultMode = "auto";
      };
    };
    host.home-manager.config.home = {
      packages = with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        claude-code
      ];

      shellAliases = {
        "claude-commit" = "claude -p 'Commit the changes in this repo'";
      };
    };
  };
}
