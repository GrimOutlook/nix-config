{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.users;
  inherit (config.host.owner) username;
  deployUser = "deploy";
  deployPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1VhVJcjb4gFXp71G6DI48D+5QHn5LhZPQzY+Si45l5 deploy@fleet";
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
          extraGroups = [ "wheel" ];

          initialHashedPassword = "$y$j9T$B1twhXiwjRRijxI5.sKdD.$ezIbul2rpq59cT/zHUDgeVygGVXcq01LDiyb4GFc79/";
        };

        # This account is intentionally not a member of wheel. Its SSH key is
        # restricted and sudo-rs permits only deploy-rs activation commands.
        ${deployUser} = {
          isSystemUser = true;
          home = "/var/lib/${deployUser}";
          createHome = true;
          group = deployUser;
          shell = pkgs.bash;
          hashedPassword = null;
          openssh.authorizedKeys.keys = [ "restrict ${deployPublicKey}" ];
        };
      };

      # NOTE: This ensures these groups are created.
      groups.${username} = { };
      groups.${deployUser} = { };
    };

    nix.settings.trusted-users = [
      "${username}"
      deployUser
    ];
  };
}
