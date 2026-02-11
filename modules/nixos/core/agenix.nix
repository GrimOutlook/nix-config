{ inputs, ... }:
{
  flake.modules.nixos.agenix =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.agenix.nixosModules.default
      ];

      environment.systemPackages = with pkgs; [
	rage
        ragenix
      ];
    };
}
