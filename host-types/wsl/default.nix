{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.host.type.wsl;
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
      shellAliases = {
        "powershell.exe" = "'/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'";
      };
    };

    # nftables seems to fail to start in WSL
    networking.nftables.enable = false;
  };
}
