{
  config,
  lib,
  ...
}:
let
  cfg = config.host.users;
  inherit (config.host.owner) username;
in
{
  options.host.users.enable = lib.mkEnableOption "Enable users configurations";
  config = lib.mkIf cfg.enable {
    users = {
      mutableUsers = false;

      users = {
        root = {
          isSystemUser = true;
          hashedPassword = null;
        };

        "${username}" = {
          isNormalUser = true;
          uid = 1000;
          homeMode = "0750";

          group = "${username}";

          initialHashedPassword = "$y$j9T$B1twhXiwjRRijxI5.sKdD.$ezIbul2rpq59cT/zHUDgeVygGVXcq01LDiyb4GFc79/";

          extraGroups = [
            "wheel"
          ];
        };
      };

      # NOTE: This ensures these groups are created.
      groups.${username} = { };
    };

    nix.settings.trusted-users = [ "${username}" ];
  };
}
