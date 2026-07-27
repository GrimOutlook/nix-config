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
        "cat"
        "cd"
        "chmod"
        "chown"
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
          ".gemini/antigravity-cli/statusline.sh" = {
            text = ''
              #!/usr/bin/env bash
              # Antigravity CLI (agy) Statusline Script
              # Formats current model, session and weekly token usage percentages from agy JSON payload stdin

              python3 -c '
              import sys, json

              try:
                  raw = sys.stdin.read()
                  data = json.loads(raw) if raw.strip() else {}
              except Exception:
                  data = {}

              # Model extraction
              model_name = None

              model_obj = data.get("model")
              if isinstance(model_obj, dict):
                  model_name = model_obj.get("display_name") or model_obj.get("name") or model_obj.get("id")
              elif isinstance(model_obj, str):
                  model_name = model_obj

              if not model_name:
                  model_name = data.get("model_name") or data.get("current_model")

              parts = []
              if model_name:
                  parts.append(f"\033[1;33mModel:\033[0m {model_name}")

              # 5-hour Session Quota Remaining percentage
              session_rem = None
              rl = data.get("rate_limits") or data.get("quota") or {}

              if isinstance(rl, dict):
                  sess_rl = rl.get("five_hour") or rl.get("session") or {}
                  if isinstance(sess_rl, dict):
                      if "remaining_percentage" in sess_rl:
                          session_rem = float(sess_rl["remaining_percentage"])
                      elif "used_percentage" in sess_rl:
                          session_rem = 100.0 - float(sess_rl["used_percentage"])

              # Weekly Quota Remaining percentage
              weekly_rem = None
              if isinstance(rl, dict):
                  wk_rl = rl.get("weekly") or rl.get("seven_day") or {}
                  if isinstance(wk_rl, dict):
                      if "remaining_percentage" in wk_rl:
                          weekly_rem = float(wk_rl["remaining_percentage"])
                      elif "used_percentage" in wk_rl:
                          weekly_rem = 100.0 - float(wk_rl["used_percentage"])

              if weekly_rem is None and isinstance(data.get("weekly"), dict):
                  wk_rl = data["weekly"]
                  if "remaining_percentage" in wk_rl:
                      weekly_rem = float(wk_rl["remaining_percentage"])
                  elif "used_percentage" in wk_rl:
                      weekly_rem = 100.0 - float(wk_rl["used_percentage"])

              def fmt(val):
                  if val is None:
                      return "100.0%"
                  try:
                      return f"{float(val):.1f}%"
                  except Exception:
                      return str(val)

              sess_str = fmt(session_rem)
              wk_str = fmt(weekly_rem)

              parts.append(f"\033[1;36mSession Quota Remaining:\033[0m {sess_str}")
              parts.append(f"\033[1;35mWeekly Quota Remaining:\033[0m {wk_str}")

              print(" | ".join(parts))
              '
            '';
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
