{ nix-config, inputs }:
let
  domains.local = "home.arpa";
  hosts.media = {
    net.ip = "192.0.2.20";
    services.plex.ports.default.number = 32400;
  };
  homelab = {
    inherit domains hosts;
    lib = nix-config.lib.mkHomelab { inherit domains hosts; };
  };
in
nix-config.lib.mkHost {
  hostname = "example";
  specialArgs = {
    inputs = inputs // {
      inherit nix-config homelab;
    };
    inherit homelab;
    host_info = hosts.media;
  };
  modules = [
    ../hosts/amsterdam/services/plex.nix
    ({ lib, ... }: {
      nixpkgs.hostPlatform = "x86_64-linux";
      host = {
        hostname = "example";
        owner = {
          username = "owner";
          name = "Example Owner";
          email = "owner@example.invalid";
        };
        gotify.url = "https://notify.example.invalid";
        default-programs.enable = false;
        custom-scripts.enable = false;
        nix-index-database.enable = false;
      };
      fileSystems."/" = {
        device = "/dev/vda1";
        fsType = "ext4";
      };
      boot.loader.grub = {
        enable = true;
        device = "/dev/vda";
      };
      # Synthetic configuration: no real login credentials or SSH keys.
      users.users.owner.hashedPassword = lib.mkForce "!";
    })
  ];
}
