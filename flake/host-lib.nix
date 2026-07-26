{ self, inputs, ... }:
let
  # Build a numtide devshell with a `deploy` command that runs
  # `nh os switch . -H <hostname>`. When run on a machine whose own hostname
  # differs from the target, it also passes `--target-host root@<hostname>`
  # so the build is activated remotely. Built from *this* flake's
  # nixpkgs/devshell inputs, so downstream flakes need no extra inputs.
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
          name = "deploy";
          help = "nh os switch this host (${hostname}); remote-targets if run elsewhere";
          command = ''
            target="${hostname}"
            if [ "$(uname -n)" = "$target" ]; then
              nh os switch . -H "$target" "$@"
            else
              nh os switch . -H "$target" --target-host "root@$target" "$@"
            fi
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
  # only needs the host-specific bits. The devShell's `deploy` command targets
  # this host.
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
        inherit system hostname commands packages;
      };
    };
in
{
  flake.lib = {
    inherit mkDeployShell mkHost;
  };
}
