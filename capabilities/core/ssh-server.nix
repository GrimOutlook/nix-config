{
  config,
  lib,
  ...
}:
let
  cfg = config.host.ssh-server;
  owner = config.host.owner.username;

  # Private/loopback ranges treated as "local". Root SSH is permitted only from
  # these; from anywhere else (the public internet) it stays disabled.
  localNetworks = builtins.concatStringsSep "," [
    "127.0.0.0/8"
    "::1"
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.168.0.0/16"
    "fc00::/7"
    "fe80::/10"
  ];
in
{
  options.host.ssh-server.enable = lib.mkEnableOption "Enable SSH server configurations";
  config = lib.mkIf cfg.enable {
    services = {
      fail2ban.enable = true;
      openssh = {
        enable = true;

        # Root SSH is disabled globally (below) but re-enabled, key-only, for
        # connections from local/private networks via the Match block in
        # extraConfig. So non-local IPs can never log in as root, local ones can.
        extraConfig = lib.mkAfter ''
          Match Address ${localNetworks}
            PermitRootLogin prohibit-password
        '';

        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;

          # Disconnect an unresponsive client after ~10 minutes.
          ClientAliveInterval = 300;
          ClientAliveCountMax = 2;

          # Drop the connection after a handful of failed auth attempts
          # instead of the default 6, to slow down brute-forcing.
          MaxAuthTries = 3;

          # Log enough to be useful for incident response and fail2ban.
          LogLevel = "VERBOSE";

          # Allow only the owner and root; any other local/system accounts are
          # rejected. root is further gated to local networks by the Match block
          # above (PermitRootLogin), so it can only be used from the LAN/VPN.
          AllowUsers = [
            owner
            "root"
          ];

          # Modern AEAD-only algorithms. Older ciphers/MACs/kex are dropped
          # rather than kept around for compatibility.
          Ciphers = [
            "chacha20-poly1305@openssh.com"
            "aes256-gcm@openssh.com"
            "aes128-gcm@openssh.com"
          ];
          Macs = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
          ];
          KexAlgorithms = [
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
        # root needs the same keys to be reachable for deploys; the Match block
        # above restricts root logins to local networks regardless.
        root.openssh.authorizedKeys.keys = keys;
      };
  };
}
