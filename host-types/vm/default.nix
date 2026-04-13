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

  config = lib.mkMerge [
    { microvm.guest.enable = lib.mkDefault false; }

    (lib.mkIf cfg.enable {
      microvm.guest.enable = true;
      microvm.hypervisor = lib.mkDefault "cloud-hypervisor";
    })
  ];

}
