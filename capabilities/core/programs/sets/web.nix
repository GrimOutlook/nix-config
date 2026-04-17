{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.web;
in
{
  options.host.default-programs.web.enable = lib.mkEnableOption "Enable default web program set";

  config.environment.systemPackages =
    with pkgs;
    lib.mkIf cfg.enable [
      # The power of curl, the ease of use of httpie.
      # https://github.com/rs/curlie
      curlie

      # Friendly and fast tool for sending HTTP requests
      # https://github.com/ducaale/xh
      xh
    ];
}
