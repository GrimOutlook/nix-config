{ inputs, self, ... }:
{
  flake.nixosConfigurations.example =
    (import ../examples/site.nix {
      inherit inputs;
      nix-config = self;
    }).nixosConfigurations.example;
}
