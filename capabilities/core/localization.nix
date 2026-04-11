{
  config,
  lib,
  ...
}:
let
  cfg = config.host.localization;
in
{
  options.host.localization.enable = lib.mkEnableOption "Enable localization configurations";

  config = lib.mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "America/Chicago";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
