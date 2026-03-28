{ config, inputs, ... }:
{
  flake.modules.nixos.wsl =
    { pkgs, ... }:
    {
      imports = [
        inputs.nixos-wsl.nixosModules.default
      ];
      wsl = {
        enable = true;
        defaultUser = config.meta.owner.username;
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
