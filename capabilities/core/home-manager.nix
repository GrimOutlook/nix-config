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
      type = types.submoduleWith {
        # This pulls in all Home Manager logic (packages, services, etc.)
        modules = [ inputs.nix-config.inputs.home-manager.nixosModules.home-manager ];
        # Allows merging multiple definitions of this option
        shorthandOnlyDefinesConfig = true;
      };

      description = "home-manager configurations that are passed to the `home-manager.users.\${owner}` field";
    };
  };

  config = mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${config.host.owner.username} = {
        imports = [ cfg.config ];
      };
    };
  };
}
