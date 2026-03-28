{ inputs, ... }:
{
  flake.modules = {
    nixos.agenix =
      { pkgs, ... }:
      {
        imports = [
          inputs.agenix.nixosModules.default
        ];

        environment.systemPackages = with pkgs; [
          rage
          ragenix
        ];
      };

    homeManager.agenix = {
      imports = [
        inputs.agenix.homeManagerModules.default
      ];
    };
  };
}
