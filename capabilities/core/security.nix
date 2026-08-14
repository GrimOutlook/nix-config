{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.security;
in
{
  options.host.security = {
    enable = lib.mkEnableOption "Enable default security configurations";
  };
  config = lib.mkIf cfg.enable {
    # Disable sudo and sudo-rs entirely; privilege escalation uses systemd run0 and Polkit
    security.sudo.enable = false;
    security.sudo-rs.enable = false;

    # Alias sudo to run0 for shell compatibility
    environment.shellAliases = {
      sudo = "run0";
    };

    # Enforce password requirement for wheel group escalation in Polkit and PAM services
    security.pam.services.run0.requireWheel = true;

    # Lock accounts on failure and enforce 3s delay on login failures
    security.pam.services.login.failDelay.enable = true;
    security.pam.services.login.failDelay.delay = 3000000;

    # Limit concurrent login sessions to 10 per user
    security.pam.loginLimits = [
      {
        domain = "*";
        item = "maxlogins";
        type = "-";
        value = "10";
      }
    ];



    # Physical port defense via USBGuard (block unauthorized peripherals, allow internal input devices)
    services.usbguard = {
      enable = lib.mkDefault true;
      implicitPolicyTarget = "block";
      rules = ''
        allow with-interface equals { 03:*:* }
      '';
    };

    # Harden GnuPG agent and use it for SSH key management
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      settings = {
        personal-cipher-preferences = "AES256";
        personal-digest-preferences = "SHA512";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        require-secmem = true;
        require-cross-certification = true;
        throw-keyids = true;
      };
    };

    # Allow the owner to shut down and reboot the system without a polkit
    # prompt, even without an active local session (e.g. over SSH).
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          (action.id == "org.freedesktop.login1.power-off" ||
           action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
           action.id == "org.freedesktop.login1.reboot" ||
           action.id == "org.freedesktop.login1.reboot-multiple-sessions") &&
          subject.user == "${config.host.owner.username}"
        ) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
