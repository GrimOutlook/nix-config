{
  config,
  lib,
  ...
}:
let
  cfg = config.host.ssh-server;
  owner = config.host.owner.username;
  localNetworks = [
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.168.0.0/16"
  ];

  # sshd is reachable from the internet, so it tracks the live Nixpkgs mirror
  # rather than the cooled pin. Pinning just the consumers we care about -- the
  # daemon and the client -- leaves `pkgs.openssh` itself on the pin. Listing
  # openssh in host.nix.realtimePackages would overlay the attribute globally
  # instead, and because gnupg takes openssh as a *build* input that orphaned
  # gnupg -> gpgme -> kwallet -> kio, and every KDE package downstream of kio,
  # from the binary cache.
  realtimeOpenssh = config.host.nix.realtimePkgs.openssh;

in
{
  options.host.ssh-server.enable = lib.mkEnableOption "Enable SSH server configurations";
  config = lib.mkIf cfg.enable {
    # The ssh client, pinned to the same build as the daemon below.
    programs.ssh.package = realtimeOpenssh;

    services = {
      fail2ban = {
        enable = true;
        bantime-increment = {
          enable = true;
          maxtime = "48h";
          factor = "2";
        };
      };
      openssh = {
        enable = true;
        package = realtimeOpenssh;
        authorizedKeysInHomedir = false;
        allowSFTP = false;

        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          X11Forwarding = false;
          AllowAgentForwarding = false;

          # Disconnect an unattended/idle session after 10 minutes (600s * 1).
          ClientAliveInterval = 600;
          ClientAliveCountMax = 1;

          # Drop the connection after a handful of failed auth attempts
          # instead of the default 6, to slow down brute-forcing.
          MaxAuthTries = 3;

          # Log enough to be useful for incident response and fail2ban.
          LogLevel = "VERBOSE";

          # The owner may log in from anywhere; the deployment credential is
          # accepted only from private LAN/VPN address space. Root has no SSH
          # entry point at all.
          AllowUsers = [ owner ] ++ map (network: "deploy@${network}") localNetworks;

          # Modern CTR and AEAD-only algorithms and SHA-2 MACs.
          Ciphers = [
            "aes256-ctr"
            "aes192-ctr"
            "aes128-ctr"
            "chacha20-poly1305@openssh.com"
            "aes256-gcm@openssh.com"
            "aes128-gcm@openssh.com"
          ];
          Macs = [
            "hmac-sha2-512"
            "hmac-sha2-256"
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
          ];
          # Post-quantum hybrids first, so sessions aren't exposed to
          # "harvest now, decrypt later". mlkem768x25519 needs OpenSSH >= 9.9,
          # sntrup761x25519 >= 8.5; the classical curve25519 entries stay as a
          # fallback for anything older.
          KexAlgorithms = [
            "mlkem768x25519-sha256"
            "sntrup761x25519-sha512@openssh.com"
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
          ];
        };
      };
    };

    users.users =
      let
        # WARN: Only development host keys should go in here. A key being in
        # here means it can access every host that enables these ssh-server
        # settings
        keys = [
          # Taipei
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBshpqm8SogcHSuol7cFNLi9R+WJR8XoWXpM6gmxLWb1 grim@taipei"
          # Belfast
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhvuDzeDBK94c5jtkKLtunFNBbiIXDfwb06PrrjDMQb grim@belfast"
          # Paris
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+VOouatDdN2oqpwfDtzJqDvrx9YJwbvs3of1aZ8Q24 grim@paris"
          # Berlin
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApGjkXLSbpQIvpIFbVeywyS8Y9rk0kQqPT5wjE/QEnX grim@berlin"
        ];
      in
      {
        ${owner}.openssh.authorizedKeys.keys = keys;
      };
  };
}
