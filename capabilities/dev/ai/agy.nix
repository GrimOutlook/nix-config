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
  agyKeybindings = [
    # Example: Unbind ctrl-k from its default action
    {
      key = "ctrl+k";
      command = "-agent.action.approve"; # Unbind default
    }
    # Example: Rebind to ctrl-y
    {
      key = "ctrl+y";
      command = "agent.action.approve";
    }
  ];
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
            text = builtins.toJSON { keybindings = agyKeybindings; };
            force = true;
          };
          ".gemini/config/settings.json" = {
            text = builtins.toJSON agySettings;
            force = true;
          };
          ".gemini/config/keybindings.json" = {
            text = builtins.toJSON { keybindings = agyKeybindings; };
            force = true;
          };
          ".gemini/antigravity-cli/statusline.sh" = {
            text = ''
              #!/usr/bin/env bash
              # Antigravity CLI (agy) Statusline Script
              # Formats current model, session and weekly token usage percentages from agy JSON payload stdin

              python3 -c '
              import sys, json, time, datetime

              try:
                  raw = sys.stdin.read()
                  data = json.loads(raw) if raw.strip() else {}
              except Exception:
                  data = {}

              def fmt_dur(seconds):
                  if seconds is None:
                      return None
                  s = int(round(seconds))
                  if s <= 0:
                      return "0m"
                  d = s // 86400
                  h = (s % 86400) // 3600
                  m = (s % 3600) // 60
                  sec = s % 60
                  if d > 0:
                      return f"{d}d {h}h" if h > 0 else f"{d}d"
                  elif h > 0:
                      return f"{h}h {m}m" if m > 0 else f"{h}h"
                  elif m > 0:
                      return f"{m}m"
                  else:
                      return f"{sec}s"

              def get_time_str(obj):
                  if not isinstance(obj, dict):
                      return None
                  for k in ["reset_in_str", "remaining_time_str", "reset_time_str", "time_remaining_str"]:
                      if k in obj and isinstance(obj[k], str) and obj[k].strip():
                          return obj[k].strip()
                  for k in ["reset_in_seconds", "reset_in", "reset_seconds", "resets_in", "remaining_seconds", "remaining_time", "ttl"]:
                      if k in obj and obj[k] is not None:
                          try:
                              return fmt_dur(float(obj[k]))
                          except Exception:
                              pass
                  for k in ["reset_time", "reset_at", "resets_at", "reset_timestamp", "reset_date", "reset"]:
                      if k in obj and obj[k] is not None:
                          val = obj[k]
                          if isinstance(val, (int, float)):
                              ts = float(val)
                              if ts > 1e11:
                                  ts /= 1000.0
                              return fmt_dur(max(0.0, ts - time.time()))
                          elif isinstance(val, str):
                              val_str = val.strip()
                              try:
                                  ts = float(val_str)
                                  if ts > 1e11:
                                      ts /= 1000.0
                                  return fmt_dur(max(0.0, ts - time.time()))
                              except Exception:
                                  pass
                              try:
                                  iso = val_str.replace("Z", "+00:00")
                                  dt = datetime.datetime.fromisoformat(iso)
                                  return fmt_dur(max(0.0, dt.timestamp() - time.time()))
                              except Exception:
                                  pass
                  return None

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

              # Quota Extraction
              quota = data.get("quota") or {}
              rl = data.get("rate_limits") or {}

              is_3p = False
              if model_name and any(x in str(model_name).lower() for x in ["claude", "sonnet", "haiku", "opus", "codestral", "3p"]):
                  is_3p = True

              # 5-hour Session Quota Remaining percentage & time
              sess_key = "3p-5h" if is_3p else "gemini-5h"
              sess_obj = quota.get(sess_key) or quota.get("gemini-5h") or quota.get("3p-5h") or {}
              session_rem = None
              sess_time_str = get_time_str(sess_obj)

              if isinstance(sess_obj, dict):
                  if "remaining_fraction" in sess_obj:
                      session_rem = float(sess_obj["remaining_fraction"]) * 100.0
                  elif "remaining_percentage" in sess_obj:
                      session_rem = float(sess_obj["remaining_percentage"])
                  elif "used_percentage" in sess_obj:
                      session_rem = 100.0 - float(sess_obj["used_percentage"])

              if session_rem is None and isinstance(rl, dict):
                  sess_rl = rl.get("five_hour") or rl.get("session") or {}
                  if isinstance(sess_rl, dict):
                      if "remaining_percentage" in sess_rl:
                          session_rem = float(sess_rl["remaining_percentage"])
                      elif "used_percentage" in sess_rl:
                          session_rem = 100.0 - float(sess_rl["used_percentage"])
                      if not sess_time_str:
                          sess_time_str = get_time_str(sess_rl)

              # Weekly Quota Remaining percentage & time
              wk_key = "3p-weekly" if is_3p else "gemini-weekly"
              wk_obj = quota.get(wk_key) or quota.get("gemini-weekly") or quota.get("3p-weekly") or {}
              weekly_rem = None
              wk_time_str = get_time_str(wk_obj)

              if isinstance(wk_obj, dict):
                  if "remaining_fraction" in wk_obj:
                      weekly_rem = float(wk_obj["remaining_fraction"]) * 100.0
                  elif "remaining_percentage" in wk_obj:
                      weekly_rem = float(wk_obj["remaining_percentage"])
                  elif "used_percentage" in wk_obj:
                      weekly_rem = 100.0 - float(wk_obj["used_percentage"])

              if weekly_rem is None and isinstance(rl, dict):
                  wk_rl = rl.get("weekly") or rl.get("seven_day") or {}
                  if isinstance(wk_rl, dict):
                      if "remaining_percentage" in wk_rl:
                          weekly_rem = float(wk_rl["remaining_percentage"])
                      elif "used_percentage" in wk_rl:
                          weekly_rem = 100.0 - float(wk_rl["used_percentage"])
                      if not wk_time_str:
                          wk_time_str = get_time_str(wk_rl)

              if weekly_rem is None and isinstance(data.get("weekly"), dict):
                  wk_rl = data["weekly"]
                  if "remaining_percentage" in wk_rl:
                      weekly_rem = float(wk_rl["remaining_percentage"])
                  elif "used_percentage" in wk_rl:
                      weekly_rem = 100.0 - float(wk_rl["used_percentage"])
                  if not wk_time_str:
                      wk_time_str = get_time_str(wk_rl)

              def fmt(val):
                  if val is None:
                      return "100.0%"
                  try:
                      return f"{float(val):.1f}%"
                  except Exception:
                      return str(val)

              sess_str = fmt(session_rem)
              wk_str = fmt(weekly_rem)

              sess_lbl = f"5 Hour Limit ({sess_time_str})" if sess_time_str else "5 Hour Limit"
              wk_lbl = f"Weekly Limit ({wk_time_str})" if wk_time_str else "Weekly Limit"

              parts.append(f"\033[1;36m{sess_lbl}:\033[0m {sess_str}")
              parts.append(f"\033[1;35m{wk_lbl}:\033[0m {wk_str}")

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
