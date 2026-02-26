{
  flake.modules.nixos.ssh-server = {
    services.openssh = {
      enable = true;

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    users.users =
      let
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBshpqm8SogcHSuol7cFNLi9R+WJR8XoWXpM6gmxLWb1 grim@taipei";
      in
      {
        root.openssh.authorizedKeys.keys = [ key ];
        grim.openssh.authorizedKeys.keys = [ key ];
      };
  };
}
