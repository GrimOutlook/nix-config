let
  # Dev-system SSH host keys. These are the only machines that receive the
  # decrypted deployment key through the host agenix module.
  berlin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApGjkXLSbpQIvpIFbVeywyS8Y9rk0kQqPT5wjE/QEnX";
  paris = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISBaMUBkrHUa1Mglwy9pT9+PT4lk+cRL7c/cUoz2Gko";

  # Keep the editor's identity as a recipient so the secret can be rekeyed
  # without access to either dev system.
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbj7iF2skCHXK7Mil4xtdrGjFr69S1wA2YtFvjLgxEG";
in
{
  "deploy-key.age" = {
    publicKeys = [
      berlin
      paris
      personal
    ];
    armor = true;
  };
}
