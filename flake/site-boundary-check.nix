{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      example = self.nixosConfigurations.example.config;
    in
    {
      checks.public-site-boundary =
        assert !(self.inputs ? homelab);
        assert builtins.attrNames example.age.secrets == [ ];
        assert example.host.owner.email == "owner@example.invalid";
        assert example.host.users.ownerPasswordFile == null;
        assert example.host.users.deployAuthorizedKeys == [ ];
        assert example.host.ssh-server.ownerAuthorizedKeys == [ ];
        pkgs.runCommand "public-site-boundary" { } ''
          touch "$out"
        '';
    };
}
