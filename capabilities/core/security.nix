{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.security;
  deployRsBridge = pkgs.writeShellScriptBin "deploy-rs-sudo-bridge" ''
    if [ "$#" -lt 2 ] || [ "$1" != root ]; then
      exit 64
    fi

    shift
    case "$1" in
      /nix/store/*/activate-rs)
        exec "$@"
        ;;
      rm)
        if [ "$#" -eq 2 ]; then
          case "$2" in
            /tmp/deploy-rs-canary-*)
              exec /run/current-system/sw/bin/rm "$2"
              ;;
          esac
        fi
        ;;
    esac

    exit 1
  '';
in
{
  options.host.security = {
    enable = lib.mkEnableOption "Enable default security configurations";
    usbguard.enable = lib.mkEnableOption "Enable USBGuard physical port defense";
  };
  config = lib.mkIf cfg.enable {
    # sudo-rs provides password-protected owner elevation and a separate
    # restricted deploy account below.
    security.sudo.enable = false;
    security.sudo-rs = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = lib.mkForce [
        {
          groups = [ "wheel" ];
          runAs = "root";
          commands = [
            {
              command = "ALL";
              options = [
                "PASSWD"
                "NOSETENV"
              ];
            }
          ];
        }
        {
          users = [ "deploy" ];
          runAs = "root";
          commands = [
            {
              # sudo-rs does not support the dynamic wildcards used by the
              # deploy-rs activation closure. The fixed bridge validates the
              # activation or canary command before executing it as root.
              command = "/run/current-system/sw/bin/deploy-rs-sudo-bridge";
              options = [
                "NOPASSWD"
                "NOSETENV"
              ];
            }
          ];
        }
        {
          users = [ config.host.owner.username ];
          runAs = "root";
          commands = [
            {
              command = "ALL";
              options = [
                "PASSWD"
                "NOSETENV"
              ];
            }
          ];
        }
      ];
    };

    # Keep sudo-rs's standard world-executable wrapper permissions. The
    # sudoers rules above provide authorization; wheel users and deploy both
    # need to be able to reach the wrapper.
    environment.systemPackages = [ deployRsBridge ];
    # run0 authorizes systemd unit management through Polkit. Deny wheel
    # subjects terminally so no later authorization rule can grant access.
    security.polkit = {
      enable = true;
      extraConfig = lib.mkBefore ''
        polkit.addRule(function(action, subject) {
          if (
            action.id == "org.freedesktop.systemd1.manage-units" &&
            subject.isInGroup("wheel")
          ) {
            return polkit.Result.NO;
          }
        });
      '';
    };
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

    # Physical port defense via USBGuard (block unauthorized peripherals, allow
    # internal input devices). Opt-in per host via
    # `host.security.usbguard.enable`: a blocking policy is only usable on a
    # host whose peripherals someone has allow-listed, because every rejected
    # device silently disappears -- it enumerates nowhere, and a rejected hub
    # takes everything behind it with it. The `equals` below is set equality
    # over the device's whole interface list, so it authorizes only
    # single-interface HID; real keyboards and mice expose several and need
    # explicit per-host rules (`services.usbguard.rules` is `types.lines`, so
    # a host's rules append to these).
    services.usbguard = lib.mkIf cfg.usbguard.enable {
      enable = true;
      implicitPolicyTarget = "block";
      rules = ''
        allow with-interface equals { 03:*:* }
      '';
    };

    # Harden GnuPG agent and use it for SSH key management
    #
    # NOTE: `programs.gnupg.agent.settings` writes to /etc/gnupg/gpg-agent.conf
    # and only accepts gpg-agent options (see `gpg-agent --dump-options`).
    # Options like cert-digest-algo, personal-cipher-preferences,
    # s2k-cipher-algo, no-comments, etc. belong in gpg.conf, not
    # gpg-agent.conf. Putting them here causes gpg-agent to fail to start
    # ("invalid option" for every line, exit status 2).
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;

      # `max-cache-ttl-ssh` is a hard ceiling: gpg-agent drops a cached SSH
      # passphrase once the entry is this old, "even if it has been accessed
      # recently", so it overrides both `default-cache-ttl-ssh` and any
      # per-key TTL in ~/.gnupg/sshcontrol. At the 2h default a key whose
      # on-disk file is passphrase-protected (the deploy credential) pops a
      # pinentry several times a working day. Raising the ceiling to ~400 days
      # makes the cache last as long as the agent does, so the passphrase is
      # entered once per boot. The key itself stays encrypted at rest in
      # ~/.gnupg/private-keys-v1.d -- this caches the passphrase, it does not
      # strip it.
      settings.max-cache-ttl-ssh = 34560000;
    };

    # gpg.conf hardening. Note: several of these duplicate hardened defaults
    # already set by home-manager's `programs.gpg` module (via `mkDefault`),
    # but are listed explicitly here for clarity/documentation purposes.
    host.home-manager.config.programs.gpg.settings = {
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
}
