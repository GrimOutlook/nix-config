{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.tide;
in
{
  options.host.default-program.tide.enable =
    lib.mkEnableOption "Enable default tide fish plugin configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fishPlugins.tide
    ];

    host.home-manager.config.programs.fish.plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];
  };
}
