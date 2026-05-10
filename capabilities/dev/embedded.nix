{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.embedded;
in
{
  options.host.dev.embedded.enable = lib.mkEnableOption "Enable embedded development configurations";

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.probe-rs-tools ];
    users.groups.plugdev = { };
    users.users.${config.host.owner.username}.extraGroups = [
      "plugdev"
      "dialout"
    ];
  };
}
