# WARN: This is what is causing the kernel panics at boot
{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.host.owner.username;
in
{
  # # Clean Quiet Boot
  # boot = {
  #   kernelParams = [
  #     "quiet"
  #     "splash"
  #     "console=/dev/null"
  #   ];
  #   plymouth.enable = true;
  # };
  #
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam.gamescopeSession.enable = true;
  };

  # Gamescope Auto Boot from TTY
  services = {
    xserver.enable = false; # Assuming no other Xserver needed
    getty.autologinUser = username;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          # Use 'journalctl -b -t gamescope' to see the logs for gamescope for
          # the current boot session
          command = ''
            bash -c '${lib.getExe pkgs.gamescope} -W 3840 -H 2160 -r 60 -f -e --xwayland-count 2 -- steam -pipewire-dmabuf -gamepadui -steamdeck 2>&1 | systemd-cat -t gamescope'
          '';
          user = username;
        };
      };
    };
  };
}
