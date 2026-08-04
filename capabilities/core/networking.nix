{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.host.networking;
in
{
  options.host.networking = {
    enable = mkEnableOption "Enable networking configurations";
    waitOnline = mkEnableOption ''
      make `network-online.target` wait for an actual connection.

      NixOS ships `NetworkManager-wait-online` as `nm-online -s`, which only
      waits for NetworkManager to *finish starting*, not for a usable address.
      On a wifi-only box NetworkManager finishes startup well before the
      association and DHCP lease complete -- and immediately if the association
      outright fails -- so `network-online.target` goes green with no IPv4
      address at all. Services ordered `After=network-online.target` then start
      into a dead network; Home Assistant in particular fails `zeroconf` setup
      with `ENODEV` and never retries, silently losing every integration that
      needs an HTTP session.

      Enable this on hosts whose services genuinely need the network at start,
      and leave it off for laptops and desktops, where it just stalls boot by up
      to a minute when no network is in range
    '';
  };
  config = mkIf cfg.enable {
    # Drop the `-s` so this waits for connectivity rather than for
    # NetworkManager's own startup. A timeout still exits nonzero and lets the
    # boot continue, so an offline host is delayed rather than stuck.
    systemd.services.NetworkManager-wait-online = mkIf cfg.waitOnline {
      serviceConfig.ExecStart = [
        ""
        "${config.networking.networkmanager.package}/bin/nm-online -q --timeout=60"
      ];
    };

    networking = {
      networkmanager.enable = mkDefault true;
      nftables.enable = mkDefault true;
      firewall = {
        enable = mkDefault true;
        logRefusedConnections = mkDefault true;
      };
    };

    # Allow the owner to connect to wifi networks and change network
    # settings (via nmcli/nmtui/nm-applet) without a polkit prompt on
    # desktop systems.
    users.users.${config.host.owner.username}.extraGroups = lib.optionals config.host.graphical.enable [
      "networkmanager"
    ];

    environment.shellAliases = {
      "clear-dns" = "sudo nscd -i hosts";
    };
  };
}
