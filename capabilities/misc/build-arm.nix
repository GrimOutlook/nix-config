{
  config,
  lib,
  ...
}:
let
  cfg = config.host.build-arm;
in
{
  options.host.build-arm.enable = lib.mkEnableOption "Enable build-arm configurations";

  config = lib.mkIf cfg.enable {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
}
