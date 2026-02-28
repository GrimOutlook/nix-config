{
  flake.modules.nixos.core =
    { config, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Command-line DNS client
        # https://github.com/ogham/dog
        # NOTE: Appears unmaintained and was last updated 5 years ago.
        dogdns

        # Ping, but with a graph
        # https://github.com/orf/gping
        gping

        # A network diagnostic tool
        # https://github.com/fujiapple852/trippy
        trippy
      ];

      environment.shellAliases = {
        dig = "dog";
        ping = "gping";
        traceroute = "trippy";
      };
    };
}
