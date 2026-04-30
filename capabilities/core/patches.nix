{
  config,
  lib,
  ...
}:
let
  cfg = config.host.patches;
in
{
  options.host.patches = {
    enable = lib.mkEnableOption "Enable default security patch configurations";
  };
  config.boot.blacklistedKernelModules = lib.mkIf cfg.enable [
    # Fixes CVE-2026-31431 -> CopyFail
    "algif_aead"
  ];
}
