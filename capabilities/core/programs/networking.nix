{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.networking;
in
{
  options.host.default-programs.networking.enable =
    lib.mkEnableOption "Enable default networking programs configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dig # Domain name server

      # Command-line DNS client
      # https://github.com/ogham/dog
      # NOTE: Appears unmaintained and was last updated 5 years ago.
      dogdns

      # Ping, but with a graph
      # https://github.com/orf/gping
      gping

      lsof

      # A network diagnostic tool
      # https://github.com/fujiapple852/trippy
      trippy
    ];

    environment.shellAliases = {
      dig = "dog";
      traceroute = "trippy";
    };
  };
}
