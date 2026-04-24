{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.jujutsu;
in
{
  options.host.dev.jujutsu.enable = lib.mkEnableOption "Enable jujutsu configuration";

  config.host.home-manager.config = lib.mkIf cfg.enable {
    # Jujutsu configuration
    programs.jujutsu = {
      enable = true;

      settings.user = {
        inherit (config.host.owner)
          name
          email
          ;
      };
    };
  };
}
