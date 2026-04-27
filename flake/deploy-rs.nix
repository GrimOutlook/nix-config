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
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostname};
      };
    };

  perSystem =
    {
      system,
      inputs',
      ...
    }:
    {
      # FIXME: This always fails because neither `config.host.hostname` nor
      # `config.networking.hostName` gets set so the `flake.deploy.nodes`
      # portion above always errors.
      # checks = deploy-rs.lib.${system}.deployChecks self.deploy;

      devshells.default.packages = [
        inputs'.deploy-rs.packages.default
      ];
    };
}
