{ports, ...}:
{
  services.vaultwarden = {
    enable = true;
    domain = "https://passwords.grimaldifamily.org";
    config = {
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = ports.vaultwarden;
    };
  };
}
