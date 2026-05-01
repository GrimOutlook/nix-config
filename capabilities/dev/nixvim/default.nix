{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.nixvim;
in
{
  options.host.dev.nixvim.enable = lib.mkEnableOption "Enable development nixvim configurations";

  config.host.dev.nixvim = lib.mkIf cfg.enable {
    plugins.enable = true;
    # features.enable = true;
  };
}
