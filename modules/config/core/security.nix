{
  flake.modules.nixos.security = {
    security = {
      sudo-rs = {
        enable = true;
        extraRules = [
          # Allow execution of any command by all users in group sudo,
          # requiring a password.
          { groups = [ "sudo" ]; commands = [ "ALL" ]; }
        ];
      };
    };
  };
}
