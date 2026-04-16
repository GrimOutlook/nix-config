{ config, lib, ... }:
with lib;
{
  options.host.auto-update.enable = lib.mkEnableOption "Enable nix auto-updates";
  config = mkIf config.host.auto-update.enable {
    system.autoUpgrade = {
      enable = true;
      flake = config.host.flake-url;
      flags = [
        "--print-build-logs"
        "--commit-lock-file" # If you want to automatically commit the updated flake.lock
      ];
      dates = "04:00";
      randomizedDelaySec = "45min";
      runGarbageCollection = true;
    };
  };
}
