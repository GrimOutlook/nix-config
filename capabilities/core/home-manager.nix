{
  config,
  inputs,
  lib,
  ...
}:
with lib;
let
  cfg = config.host.home-manager;
in
{

  imports = [
    inputs.nix-config.inputs.home-manager.nixosModules.default
  ];

  options.host.home-manager = {
    enable = mkEnableOption "Enable home-manager configurations";

    config = mkOption {
      type = types.deferredModule;
      default = { };
      description = ''
        home-manager configurations passed to the `home-manager.sharedModules`
        field, i.e. applied to *every* home-manager user, not just the owner.

        This is the default place for configuration: a second user on a host
        should get the same shell, editor, tooling and keybinds as the owner.
        Anything that is genuinely tied to the owner as a person (an identity,
        a personal secret) belongs in `ownerConfig` instead.

        Modules here must not hardcode the owner's home directory. Take the
        module's function form (`{ config, ... }: ...`) and use home-manager's
        own `config.home.homeDirectory` / `config.xdg.*` so each user resolves
        to their own paths.
      '';
    };

    ownerConfig = mkOption {
      type = types.deferredModule;
      default = { };
      description = "home-manager configurations that are passed to the `home-manager.users.\${owner}` field only";
    };
  };

  config.home-manager =
    let
      inherit (config.host.owner) username;
    in
    mkIf cfg.enable {
      backupFileExtension = "hm-bkp";
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ cfg.config ];
      users.${username} = {
        home.homeDirectory = "/home/${username}";

        imports = [ cfg.ownerConfig ];
      };
    };
}
