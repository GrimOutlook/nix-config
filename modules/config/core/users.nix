{config, ...}:
let
  username = config.meta.owner.username;
in
{
  flake.modules.nixos.users = {
    users = {
      mutableUsers = false;

      users = {
        root = {
          isSystemUser = true;
        };

        "${username}" = {
          isNormalUser = true;
          uid = 1000;

          group = "${username}";

          initialHashedPassword = 
            "$y$j9T$B1twhXiwjRRijxI5.sKdD.$ezIbul2rpq59cT/zHUDgeVygGVXcq01LDiyb4GFc79/";
          
          extraGroups = [
            # Enable ‘sudo’ for the user.
            "sudo"
          ];
        };
      };
      groups."${username}" = {};
      groups.sudo = {};
    };
    nix.settings.trusted-users = [ "${username}" ];
  };
}
