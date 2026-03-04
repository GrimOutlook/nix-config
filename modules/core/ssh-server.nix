{
  flake.modules.nixos.ssh-server = {
    services.openssh = {
      enable = true;

      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    users.users =
      let
        taipei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBshpqm8SogcHSuol7cFNLi9R+WJR8XoWXpM6gmxLWb1 grim@taipei";
        belfast = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhvuDzeDBK94c5jtkKLtunFNBbiIXDfwb06PrrjDMQb grim@belfast";
        keys = [
          taipei
          belfast
        ];
      in
      {
        root.openssh.authorizedKeys.keys = keys;
        grim.openssh.authorizedKeys.keys = keys;
      };
  };
}
