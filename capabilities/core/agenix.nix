{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.agenix;
in
{
  options.host.agenix = {
    enable = lib.mkEnableOption "Enable agenix configurations";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rage
      ragenix
    ];
  };
}
