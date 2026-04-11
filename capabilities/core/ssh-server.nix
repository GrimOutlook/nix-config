{
  config,
  lib,
  ...
}:
let
  cfg = config.host.ssh-server;
  owner = config.host.owner.username;
in
{
  options.host.ssh-server.enable = lib.mkEnableOption "Enable SSH server configurations";
  config = lib.mkIf cfg.enable {
    services = {
      fail2ban.enable = true;
      openssh = {
        enable = true;

        settings = {
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHw6y8P3yv2xkLTl93JhF4DiCHjWrk0RzlY1Iwdz7tJL grim@paris"
          # Berlin
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApGjkXLSbpQIvpIFbVeywyS8Y9rk0kQqPT5wjE/QEnX grim@berlin"
        ];
      in
      {
        root.openssh.authorizedKeys.keys = keys;
        ${owner}.openssh.authorizedKeys.keys = keys;
      };
  };
}
