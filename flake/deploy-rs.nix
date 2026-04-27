{
  inputs,
  self,
  config,
  ...
}:
let
  inherit (inputs) deploy-rs;
  inherit (config.host) hostname;
  inherit (config) system;
in
{
  flake = {
    deploy.nodes = {
      inherit hostname;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostname};
      };
    };
  };

  perSystem =
    {
      system,
      inputs',
      ...
    }:
    {
      checks = deploy-rs.lib.${system}.deployChecks self.deploy;

      devshells.default.packages = [
        inputs'.deploy-rs.packages.default
      ];
    };
}
