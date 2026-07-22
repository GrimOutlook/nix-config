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
    permissions = {
      allow = [
        "command(file)"
        "command(ls)"
        "command(git status)"
        "command(git diff)"
        "command(git add)"
        "command(git commit)"
        "command(git log)"
        "command(git checkout)"
        "command(git stash)"
        "command(git branch)"
        "command(git pull)"
        "command(journalctl -n 50)"
        "command(systemctl status)"
        "command(head)"
        "command(grep)"
        "command(rg)"
        "command(find)"
        "command(fd)"
        "command(sed)"
        "command(sd)"
        "command(nix-instantiate)"
        "command(nix eval)"
        "command(nix build)"
        "command(podman run)"
        "command(podman images)"
        "command(podman exec)"
        "command(podman build)"
        "command(docker run)"
        "command(docker images)"
        "command(docker exec)"
        "command(docker build)"
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
          ".gemini/antigravity-cli/settings.json".text = builtins.toJSON agySettings;
          ".gemini/config/settings.json".text = builtins.toJSON agySettings;
        };
        packages = with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
          antigravity-cli
        ];
      };
    };
  };
}
