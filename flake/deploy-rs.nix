{
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      # Actual nodes are assembled by the private site using lib.mkFleetDeploy.

      # nixpkgs' build rather than `inputs'.deploy-rs.packages.default`: the
      # input builds against its own older nixpkgs, whose `fetchCrate` still
      # uses the crates.io API URL that now 403s, and nothing caches that
      # derivation. The nixpkgs build is on cache.nixos.org.
      devshells.default.packages = [
        pkgs.deploy-rs
      ];
    };
}
