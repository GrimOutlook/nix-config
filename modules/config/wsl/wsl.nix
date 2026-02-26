{ config, inputs, ... }:
{
  flake.modules.nixos.wsl = {
    imports = [
      inputs.nixos-wsl.nixosModules.default
    ];

    wsl.enable = true;
    wsl.defaultUser = config.meta.owner.username;
    # NOTE: Including the path slows down commands and bash-completion
    # significantly
    wsl.interop.includePath = false;
    wsl.wslConf.interop.appendWindowsPath = false;
  };
}
