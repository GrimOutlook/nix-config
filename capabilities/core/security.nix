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
  };
  config = lib.mkIf cfg.enable {
    # sudo-rs is retained only for the restricted deploy account below. The
    # owner uses run0/Polkit for local elevation instead of generic sudo.
    security.sudo.enable = false;
    security.sudo-rs = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = lib.mkForce [
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
      ];
    };

    environment.systemPackages = [ deployRsBridge ];

    # Restrict the privileged wrappers themselves to the deploy group. The
    # package in the Nix store remains world-readable/executable, but it is not
    # setuid and cannot elevate without these wrappers.
    security.wrappers.sudo = {
      group = lib.mkForce "deploy";
      permissions = lib.mkForce "u+rx,g+x";
    };
    security.wrappers.sudoedit = {
      group = lib.mkForce "deploy";
      permissions = lib.mkForce "u+rx,g+x";
    };
    # Require local run0 users to be in wheel; the active-session Polkit rule
    # below remains the gate that prevents remote owner SSH sessions escalating.
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

      // Allow the owner to manage systemd units (e.g. via `run0`, used by
      // `nh`/`deploy` to activate NixOS configurations) without a polkit
      // password prompt, but only from an active local session so this
      // can't be abused remotely without already having a shell as the
      // owner.
      polkit.addRule(function(action, subject) {
        if (
          action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "${config.host.owner.username}" &&
          subject.active
        ) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
