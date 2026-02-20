{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption;

  # Capture nix-config's inputs and modules for use in exported module
  nixConfigInputs = inputs;
  nixConfigModules = config.flake.modules;

  mkHostsModule =
    ncInputs: ncModules:
    { lib, config, ... }:
    let
      inherit (lib) types mkOption;

      baseHostModule =
        { config, ... }:
        {
          options = {
            arch = mkOption {
              type = types.str;
              default = "x86_64-linux";
              description = "The system architecture (e.g., x86_64-linux, aarch64-linux)";
            };

            unstable = mkOption {
              type = types.bool;
              default = false;
            };

            modules = mkOption {
              type = with types; listOf deferredModule;
              default = [ ];
            };

            nixpkgs = mkOption {
              type = types.pathInStore;
            };

            pkgs = mkOption {
              type = types.pkgs;
            };
          };

          config = {
            nixpkgs = if config.unstable then ncInputs.nixpkgs-unstable else ncInputs.nixpkgs;
            pkgs = import config.nixpkgs {
              system = config.arch;
              config.allowUnfree = true;
            };
          };
        };

      # Freeform module that captures all non-option attributes as passthru config
      freeformHostModule = {
        freeformType = types.attrsOf types.anything;
      };

      nixosHostType = types.submodule [ baseHostModule freeformHostModule ];
      homeHostType = types.submodule [ baseHostModule freeformHostModule ];

      hostType = types.submodule {
        options = {
          nixos = mkOption {
            type = types.nullOr nixosHostType;
            default = null;
          };
          home = mkOption {
            type = types.nullOr homeHostType;
            default = null;
          };
        };
      };
    in
    let
      # Options managed by the hosts module itself (not passed through to NixOS/home-manager)
      hostModuleOptions = [ "arch" "unstable" "modules" "nixpkgs" "pkgs" ];

      # Extract freeform config (everything except our managed options)
      extractPassthruConfig = hostConfig:
        lib.filterAttrs (name: _: !lib.elem name hostModuleOptions) hostConfig;
    in
    {
      options.host = mkOption {
        type = types.attrsOf hostType;
        default = { };
      };

      config.flake = {
        nixosConfigurations = lib.mapAttrs (
          hostname: hostConfig:
          let
            passthruConfig = extractPassthruConfig hostConfig.nixos;
          in
          hostConfig.nixos.nixpkgs.lib.nixosSystem {
            system = hostConfig.nixos.arch;
            modules =
              [
                ncModules.nixos.core
                { networking.hostName = hostname; }
                passthruConfig
              ]
              ++ hostConfig.nixos.modules;
            specialArgs.inputs = ncInputs;
          }
        ) (lib.filterAttrs (_: v: v.nixos != null) config.host);

        homeConfigurations = lib.mapAttrs (
          configName: hostConfig:
          let
            passthruConfig = extractPassthruConfig hostConfig.home;
          in
          ncInputs.home-manager.lib.homeManagerConfiguration {
            extraSpecialArgs = {
              inputs = ncInputs;
              inherit configName;
              nhSwitchCommand = "nh home switch --configuration ${configName}";
              nhFlake = config.host-info.flake;
            };
            inherit (hostConfig.home) pkgs;
            modules =
              [
                ncModules.homeManager.core
                (
                  { pkgs, config, ... }:
                  {
                    nix.package = pkgs.nix;
                    age.identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ];
                  }
                )
                passthruConfig
              ]
              ++ hostConfig.home.modules;
          }
        ) (lib.filterAttrs (_: v: v.home != null) config.host);
      };
    };
in
{
  imports = [ (mkHostsModule nixConfigInputs nixConfigModules) ];

  config.flake.modules.flake.hosts = mkHostsModule nixConfigInputs nixConfigModules;
}
