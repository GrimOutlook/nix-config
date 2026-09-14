{ self, inputs, ... }:
let
  # Build a numtide devshell with repository maintenance commands. Built from
  # *this* flake's nixpkgs/devshell inputs, so downstream flakes need no extra
  # inputs.
  mkDeployShell =
    {
      system,
      hostname,
      # Extra numtide-devshell command entries to append.
      commands ? [ ],
      # Extra packages to put on PATH in the shell.
      packages ? [ ],
    }:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    inputs.devshell.legacyPackages.${system}.mkShell {
      packages = [ pkgs.nh ] ++ packages;
      commands = [
        {
          name = "commit-update";
          help = "Commit the flake.lock update";
          command = ''
            git commit -m "chore: Update flake.lock" flake.lock
          '';
        }
      ]
      ++ commands;
    };

  # Generate a host flake's `nixosConfigurations.<hostname>` and
  # `devShells.<system>.default` outputs in a single call, so the hostname and
  # system are each written exactly once.
  #
  #   outputs =
  #     inputs@{ nix-config, homelab, ... }:
  #     nix-config.lib.mkHost {
  #       hostname = "newyork";
  #       system = "x86_64-linux";
  #       specialArgs = { inherit inputs homelab; };
  #       modules = [ ./modules ];
  #     };
  #
  # `nix-config.nixosModules.default` is included automatically, so `modules`
  # only needs the host-specific bits. The devShell provides repository
  # maintenance commands.
  mkHost =
    {
      hostname,
      system ? "x86_64-linux",
      # Host-specific NixOS modules (nix-config's default module is prepended).
      modules ? [ ],
      # specialArgs passed through to nixosSystem.
      specialArgs ? { },
      # Forwarded to the devshell.
      commands ? [ ],
      packages ? [ ],
    }:
    {
      nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [ self.nixosModules.default ] ++ modules;
      };

      devShells.${system}.default = mkDeployShell {
        inherit
          system
          hostname
          commands
          packages
          ;
      };
    };
in
{
  flake.lib = {
    inherit mkDeployShell mkHost;
  };
}
