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
in
{
  options.host.users = {
    enable = lib.mkEnableOption "Enable users configurations";
    ownerPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Runtime file containing the owner's password hash; supplied by the private site.";
    };
    deployAuthorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Public deployment keys; each is installed with the restrict flag.";
    };
  };
  config = lib.mkIf cfg.enable {
    users = {
      mutableUsers = false;

      # The owner is deliberately not in wheel; elevation goes through the
      # password-protected sudo-rs rule in security.nix and login through the
      # SSH key set in ssh-server.nix. The stock lockout assertion only counts
      # hashedPassword/hashedPasswordFile/authorized keys on root or wheel
      # accounts, so it sees neither and would otherwise fail every build.
      allowNoPasswordLogin = true;

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

          hashedPasswordFile = cfg.ownerPasswordFile;
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
          openssh.authorizedKeys.keys = map (key: "restrict ${key}") cfg.deployAuthorizedKeys;
        };
      };

      # NOTE: This ensures these groups are created.
      groups.${username} = { };
      groups.${deployUser} = { };
      groups.users.members = lib.unique ([ username ] ++ lib.attrNames config.home-manager.users);
      groups."sudo-rs-callers" = {
        members = [
          username
          deployUser
        ];
      };
    };

    nix.settings.trusted-users = [
      "${username}"
      deployUser
    ];
  };
}
