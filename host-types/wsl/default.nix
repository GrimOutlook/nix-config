{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.type.wsl;

  # Windows interop binaries aren't on $PATH since interop.includePath is
  # disabled above. shellAliases (fish functions) cover interactive use, but
  # tools like tmux shell out via `command -v <name>`/`sh -c`, which only see
  # real executables on $PATH, not fish functions. Wrap both binaries as real
  # executables so every caller -- interactive shell, tmux, scripts -- finds
  # them the same way.
  clipExe = pkgs.writeShellApplication {
    name = "clip.exe";
    text = ''
      exec '/mnt/c/Windows/System32/clip.exe' "$@"
    '';
  };
  powershellExe = pkgs.writeShellApplication {
    name = "powershell.exe";
    text = ''
      exec '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe' "$@"
    '';
  };
in
{
  imports = [
    inputs.nix-config.inputs.nixos-wsl.nixosModules.default
  ];

  options.host.type.wsl.enable = lib.mkEnableOption "Enable WSL configurations";

  config = lib.mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = config.host.owner.username;
      # NOTE: Including the path slows down commands and bash-completion
      # significantly. We include some paths manually where desired.
      interop.includePath = false;
      wslConf.interop.appendWindowsPath = false;
    };
    environment = {
      systemPackages = with pkgs; [
        clipExe
        powershellExe
        wl-clipboard
      ];
    };

    # nftables seems to fail to start in WSL
    networking.nftables.enable = false;

    # wpa_supplicant fails to start in WSL due to namespace restrictions and is not needed
    networking.wireless.enable = lib.mkForce false;
    systemd.services.wpa_supplicant.enable = lib.mkForce false;

    # WSL does not expose the USB device tree that usbguard requires.
    services.usbguard.enable = false;
  };
}
