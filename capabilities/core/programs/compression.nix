{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.compression;
in
{
  options.host.default-programs.compression.enable =
    lib.mkEnableOption "Enable default compression programs configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Painless compression and decompression in the terminal
      # https://github.com/ouch-org/ouch
      ouch

      unzip
      zip
    ];
  };
}
