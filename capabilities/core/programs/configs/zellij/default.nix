{
  config,
  lib,
  ...
}:
let
  cfg = config.host.default-program.zellij;
in
{
  options.host.default-program.zellij.enable =
    lib.mkEnableOption "Enable default zellij configurations";

  config.host.home-manager.config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
