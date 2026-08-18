{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.puffer;
in
{
  options.host.default-program.puffer.enable =
    lib.mkEnableOption "Enable default puffer-fish plugin configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fishPlugins.puffer
    ];

    host.home-manager.config.programs.fish = {
      plugins = [
        {
          name = "puffer";
          src = pkgs.fishPlugins.puffer.src;
        }
      ];
    };
  };
}
