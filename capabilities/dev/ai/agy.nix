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
    ui = {
      showTokenUsage = true;
    };
    permissions = {
      allow = builtins.map (cmd: "command(${cmd})") [
        "awk"
        "cat"
        "cd"
        "docker build"
        "docker exec"
        "docker images"
        "docker run"
        "echo"
        "fd"
        "file"
        "find"
        "git"
        "grep"
        "head"
        "journalctl"
        "ls"
        "nix build"
        "nix eval"
        "nix flake check"
        "nix flake upgrade"
        "nix-instantiate"
        "podman build"
        "podman exec"
        "podman images"
        "podman run"
        "rg"
        "sd"
        "sed"
        "sort"
        "systemctl"
        "tee"
        "uniq"
        "wc"
      ];
    };
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
          ".gemini/config/settings.json" = {
            text = builtins.toJSON agySettings;
            force = true;
          };
        };
        packages = with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
          antigravity-cli
        ];
      };
    };
  };
}
