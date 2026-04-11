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
        root.isSystemUser = true;

        "${username}" = {
          isNormalUser = true;
          uid = 1000;

          group = "${username}";

          initialHashedPassword = "$y$j9T$B1twhXiwjRRijxI5.sKdD.$ezIbul2rpq59cT/zHUDgeVygGVXcq01LDiyb4GFc79/";

          extraGroups = [
            "wheel"

            # Enable ‘sudo’ for the user.
            "sudo"
          ];
        };
      };

      # NOTE: This ensures these groups are created.
      groups.${username} = { };
      groups.sudo = { };
    };

    nix.settings.trusted-users = [ "${username}" ];
  };
}
