{ ... }:
let
  hostNames = builtins.attrNames (builtins.readDir ../hosts);
in
{
  flake.nixosModules = builtins.listToAttrs (
    map (name: {
      name = "host-${name}";
      value = ../hosts + "/${name}";
    }) hostNames
  );
}
