{
  config,
  lib,
  ...
}:
let
  cfg = config.host.type.virtual-machine;
in
{
  options.host.type.virtual-machine.enable =
    lib.mkEnableOption "Enable virtual-machine configurations";

  config = lib.mkIf cfg.enable {
    # A Rust based QEMU alternative.
    microvm.hypervisor = lib.mkDefault "cloud-hypervisor";
  };
}
