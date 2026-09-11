{
  inputs,
  self,
  config,
  ...
}:
let
  inherit (inputs) deploy-rs;
  inherit (config) system;
in
{
  flake.deploy.nodes =
    let
      hostname = config.host.hostname;
    in
    {
      inherit hostname;
      sshUser = "deploy";
      sudo = "sudo -n -u root /run/current-system/sw/bin/deploy-rs-sudo-bridge";
      interactiveSudo = false;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostname};
      };
    };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      # FIXME: This always fails because neither `config.host.hostname` nor
      # `config.networking.hostName` gets set so the `flake.deploy.nodes`
      # portion above always errors.
      # checks = deploy-rs.lib.${system}.deployChecks self.deploy;

      # nixpkgs' build rather than `inputs'.deploy-rs.packages.default`: the
      # input builds against its own older nixpkgs, whose `fetchCrate` still
      # uses the crates.io API URL that now 403s, and nothing caches that
      # derivation. The nixpkgs build is on cache.nixos.org.
      devshells.default.packages = [
        pkgs.deploy-rs
      ];
    };
}
