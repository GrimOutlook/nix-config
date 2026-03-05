{ config, inputs, ... }:
{
  flake.modules.nixos.wsl = {
    imports = [
      inputs.nixos-wsl.nixosModules.default
    ];
    wsl = {
      enable = true;
      defaultUser = config.meta.owner.username;
      # NOTE: Including the path slows down commands and bash-completion
      # significantly
      interop.includePath = false;
      wslConf.interop.appendWindowsPath = false;
    };

    # nftables seeems to fail to start in WSL
    networking.nftables.enable = false;
  };
}
