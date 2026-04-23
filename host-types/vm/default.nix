{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.host.type.virtual-machine;
in
{
  imports = [
    inputs.nix-config.inputs.microvm.nixosModules.microvm
  ];

  options.host.type.virtual-machine.enable =
    lib.mkEnableOption "Enable virtual-machine configurations";

  config = {
    microvm = {
      guest.enable = cfg.enable;
      hypervisor = lib.mkDefault "cloud-hypervisor";
    };
    # host.metrics = true;
    # notifications.ssh-server = true;
  };

}
