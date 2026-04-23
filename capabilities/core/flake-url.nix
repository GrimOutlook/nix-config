{
  config,
  lib,
  ...
}:
let
  hostname = config.host.hostname;
in
{
  options.host.flake-url = lib.mkOption {
    type = lib.types.str;
    default = "github+ssh://github.com/GrimOutlook/nix-host-${hostname}";
    description = "URL to flake";
  };
}
