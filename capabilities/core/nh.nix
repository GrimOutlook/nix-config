{
  config,
  lib,
  ...
}:
let
  cfg = config.host.nh;
in
{
  options.host.nh = {
    enable = lib.mkEnableOption "Enable nh configurations";
  };
  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      u = "nh os switch";
      nix-collect-garbage = "echo 'Use `nh clean` instead!'";
    };

    programs.nh = {
      enable = true;

      flake = config.host.flake-url;

      clean = {
        enable = true;

        dates = "daily";
        extraArgs = "--keep 1 --keep-since 8d";
      };
    };
  };
}
