# Single source of truth for what every AI CLI is allowed to do.
#
# Each tool spells these out in its own syntax -- Claude wants `Bash(git:*)`,
# Antigravity wants `command(git)`, OpenCode wants glob keys -- so the lists
# here are plain values and every tool module renders them itself. Change the
# defaults below (or set the options from a host) and every tool follows.
{
  config,
  lib,
  ...
}:
let
  homeDirectory = "/home/${config.host.owner.username}";
in
{
  options.host.dev.ai.shared = {
    allowedCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        Commands every AI tool may run without asking. Entries are command
        prefixes, so "docker build" permits any `docker build ...` invocation.
      '';
      default = [
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
    };

    deniedCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Command prefixes no AI tool may run, whatever else allows them.";
      default = [ "rm -rf" ];
    };

    allowedDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        Absolute directories every AI tool may reach outside the workspace.
        Per-tool scratch directories (/tmp/claude, /tmp/opencode, ...) are added
        by the tool modules themselves.
      '';
      default = [
        "/nix/store"
        "/nix/var/log/nix"
        "/nix/var/nix/profiles"
        "/run/current-system"
        "${homeDirectory}/.local/state/nix/profiles"
      ];
    };
  };
}
