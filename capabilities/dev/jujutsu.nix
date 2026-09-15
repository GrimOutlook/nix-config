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

  config.host.home-manager = {
    config = lib.mkIf cfg.enable {
      programs.jujutsu.enable = true;
    };

    # As with git, the author identity stays on the owner.
    ownerConfig = lib.mkIf cfg.enable {
      programs.jujutsu.settings.user = {
        inherit (config.host.owner)
          name
          email
          ;
      };
    };
  };
}
