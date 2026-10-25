{ lib, ... }:
let
  mkStrOpt =
    description:
    (lib.mkOption {
      type = lib.types.str;
      inherit description;
    });
in
{
  options.host.owner = {
    email = mkStrOpt "Email of the main user, supplied by the site";
    name = mkStrOpt "Name of the main user, supplied by the site";
    username = mkStrOpt "Username for the main user, supplied by the site";
  };
}
