{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.agy;
  agySettings = {
    allowNonWorkspaceAccess = true;
    colorScheme = "dark";
    enableTelemetry = false;
    statusLine = {
      enabled = true;
      type = "command";
      command = "/home/grim/.gemini/antigravity-cli/statusline.sh";
    };
    ui = {
      showTokenUsage = true;
    };
    permissions = {
      allow = builtins.map (cmd: "command(${cmd})") [
        "awk"
        "binwalk"
        "cat"
        "cd"
        "chmod"
        "chown"
        "cp"
        "curl"
        "devenv"
        "df"
        "diff"
        "docker build"
        "docker exec"
        "docker images"
        "docker run"
        "du"
        "echo"
        "export"
        "fd"
        "file"
        "find"
        "gh issue"
        "gh pr"
        "gh repo"
        "gh search"
        "git"
        "go vet"
        "grep"
        "head"
        "journalctl"
        "jq"
        "just"
        "kill"
        "ls"
        "mage"
        "mkdir"
        "mv"
        "nix build"
        "nix eval"
        "nix flake check"
        "nix flake upgrade"
        "nix-instantiate"
        "podman build"
        "podman exec"
        "podman images"
        "podman run"
        "ps"
        "rg"
        "rmdir"
        "sd"
        "sed"
        "sort"
        "stat"
        "strings"
        "systemctl"
        "tail"
        "tar"
        "tee"
        "top"
        "touch"
        "tree"
        "uniq"
        "unzip"
        "wc"
        "wget"
        "which"
        "xargs"
        "zip"
      ];
      deny = builtins.map (cmd: "command(${cmd})") [
        "rm -rf"
      ];
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
    host.home-manager.config = {
      home = {
        file = {
          ".gemini/antigravity-cli/settings.json" = {
            text = builtins.toJSON agySettings;
            force = true;
          };
          ".gemini/antigravity-cli/keybindings.json" = {
            text = builtins.toJSON agyKeybindings;
            force = true;
          };
          ".gemini/config/settings.json" = {
            text = builtins.toJSON agySettings;
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
      };
    };
  };
}
