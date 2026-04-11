{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.sound;
in
{
  options.host.sound.enable = lib.mkEnableOption "Enable sound (pipewire)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pavucontrol
    ];
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
