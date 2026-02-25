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

    in
    let
      # Options managed by the hosts module itself (not passed through to NixOS/home-manager)
      hostModuleOptions = [ "name" "arch" "unstable" "modules" "nixpkgs" "pkgs" ];

      # Extract freeform config (everything except our managed options)
      extractPassthruConfig = hostConfig:
        lib.filterAttrs (name: _: !lib.elem name hostModuleOptions) hostConfig;

      # Resolve a module name to an actual module if it exists in the given module set
      resolveModule = moduleSet: moduleName:
        if moduleSet ? ${moduleName} then moduleSet.${moduleName} else null;

      # Get all resolved modules from a list of module names for a given module set
      resolveModules = moduleSet: moduleNames:
        lib.filter (m: m != null) (map (resolveModule moduleSet) moduleNames);
    in
    {
      options = {
        modules = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = ''
            List of module names to apply to both nixos and home configurations.
            Each name is checked against ncModules.nixos and ncModules.homeManager.
            If a module exists in either, it is automatically included in that configuration.
          '';
        };
        nixos = mkOption {
          type = types.nullOr nixosHostType;
          default = null;
        };
        home = mkOption {
          type = types.nullOr homeHostType;
          default = null;
        };
      };

      config.flake = {
        nixosConfigurations = lib.mkIf (config.nixos != null) {
          ${config.host-info.name} =
            let
              passthruConfig = extractPassthruConfig config.nixos;
              # Resolve top-level modules for nixos
              resolvedNixosModules = resolveModules ncModules.nixos config.modules;
            in
            config.nixos.nixpkgs.lib.nixosSystem {
              system = config.nixos.arch;
              modules =
                [
                  ncModules.nixos.core
                  { networking.hostName = config.host-info.name; }
                  passthruConfig
                ]
                ++ resolvedNixosModules
                ++ config.nixos.modules;
              specialArgs.inputs = ncInputs;
            };
        };

        homeConfigurations = lib.mkIf (config.home != null) {
          ${config.host-info.name} =
            let
              passthruConfig = extractPassthruConfig config.home;
              configName = config.host-info.name;
              # Resolve top-level modules for homeManager
              resolvedHomeModules = resolveModules ncModules.homeManager config.modules;
            in
            ncInputs.home-manager.lib.homeManagerConfiguration {
              extraSpecialArgs = {
                inputs = ncInputs;
                inherit configName;
                nhSwitchCommand = "nh home switch --configuration ${configName}";
                nhFlake = config.host-info.flake;
              };
              inherit (config.home) pkgs;
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
                ++ resolvedHomeModules
                ++ config.home.modules;
            };
        };

        # Generate checks for home configuration
        checks = lib.mkIf (config.home != null) {
          ${config.home.arch}."home-${config.host-info.name}" =
            config.flake.homeConfigurations.${config.host-info.name}.activationPackage;
        };
      };
    };
in
{
  imports = [ (mkHostsModule nixConfigInputs nixConfigModules) ];

  config.flake.modules.flake.hosts = mkHostsModule nixConfigInputs nixConfigModules;
}
