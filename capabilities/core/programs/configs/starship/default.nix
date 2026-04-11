{
  config,
  lib,
  ...
}:
let
  cfg = config.host.default-program.starship;
in
{
  options.host.default-program.starship.enable =
    lib.mkEnableOption "Enable default starship configurations";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = lib.importTOML ./starship.toml;
    };
  };
}
