{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.notifications.ssh-server;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  hostname = cfg.host.hostname;
in
{
  options.host.notifications.ssh-server = {
    enable = mkEnableOption "Enable SSH server notifications";
    url = mkOption {
      type = types.string;
      description = "Gotify URL";
      example = "https://gotify.example.com";
    };
    apiKeyFile = mkOption {
      type = types.path;
      description = "Path to a file containing a Gotify API key";
    };
    success.enable = mkEnableOption "Enable SSH server notifications for successful logins" // {
      default = true;
    };
    banned.enable = mkEnableOption "Enable SSH server notifications for banned hosts" // {
      default = true;
    };
  };
  config = {
    # -- Success Section ------------------------------------------------------
    security.pam.services.sshd.text =
      let
        sshNotify = pkgs.writeShellScript "gotify-ssh-notify.sh" ''
          # Read the decrypted token from the agenix path
          TOKEN=$(cat "${cfg.apiKeyFile}")

          if [ "$PAM_TYPE" != "close_session" ]; then
            MSG="User '$PAM_USER' logged in to ${hostname} from '$PAM_RHOST'"

            ${pkgs.xh}/bin/xh -s POST "${cfg.url}/message" \
            "X-Gotify-Key:$TOKEN" \
            title="SSH Login on ${hostname}" \
            message="$MSG" \
            priority:=10
          fi
        '';
      in
      mkIf (cfg.enable && cfg.success.enable) ''
        session optional ${pkgs.pam_exec}/lib/security/pam_exec.so ${sshNotify}
      '';

    # -- Banned Section -------------------------------------------------------
    environment.etc."fail2ban/action.d/ssh-gotify.conf".text = mkIf (cfg.enable && cfg.banned.enable) ''
      [Definition]
      actionban = ${pkgs.xh}/bin/xh -s POST "${cfg.url}/message" \
                  "X-Gotify-Key:$(cat ${cfg.apiKeyFile})" \
                  title="Banned on ${hostname}" \
                  message="Banned <ip> after <failures> attempts against <name>" \
                  priority:=7
      actionunban = ${pkgs.xh}/bin/xh -s POST "${cfg.url}/message" \
                  "X-Gotify-Key:$(cat ${cfg.apiKeyFile})" \
                  title="Unbanned on ${hostname}" \
                  message="Unbanned <ip>" \
                  priority:=2
    '';

    services.fail2ban = mkIf (cfg.enable && cfg.banned.enable) {
      enable = true;

      # `%(action_)s` tells fail2ban to ban them only (without sending out
      # an email since it's not setup) and we just append our new action to
      # that.
      jails.sshd.settings.action = "%(action_)s[name=SSH, action=gotify]";
    };
  };
}
