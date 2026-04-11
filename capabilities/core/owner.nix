{ lib, ... }:
let
  mkDefaultStrOpt =
    default: description:
    (lib.mkOption {
      type = lib.types.str;
      inherit default;
      inherit description;
    });
in
{
  options.host.owner = {
    email = mkDefaultStrOpt "dev@grimoutlook.dev" "Email of the main user";
    name = mkDefaultStrOpt "Dominic Grimaldi" "Name of the main user";
    username = mkDefaultStrOpt "grim" "Username for the main user";
  };
}
