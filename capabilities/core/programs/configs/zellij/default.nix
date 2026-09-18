{
  config,
  lib,
  nixpkgsUnstable,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.zellij;
  zellij = nixpkgsUnstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zellij;
in
{
  options.host.default-program.zellij.enable =
    lib.mkEnableOption "Enable default zellij configurations";

  config.host.home-manager.config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      package = zellij;
      enableFishIntegration = true;
      extraConfig = builtins.readFile ./config.kdl;
    };
  };
}
