{ inputs, pkgs, ... }:
{
  host = {
    bluetooth.enable = true;
    build-arm.enable = true;
    dev = {
      enable = true;
      lang = {
        nix.enable = true;
        python.enable = true;
        rust.enable = true;
      };
    };
    hostname = "berlin";
    network-diag.enable = true;
    type.desktop.enable = true;
    virtualization.enable = true;
  };

  host.nix.realtimePackages = [ "chromium" ];

  environment.systemPackages = with pkgs; [
    chromium
    obsidian
    efibootmgr
    kdePackages.kdenlive
  ];

  # USBGuard allow-list for the peripherals attached to berlin. The default
  # policy in config/capabilities/core/security.nix only allows devices whose
  # interface set is exactly { 03:*:* }, which excludes multi-interface HID
  # devices, so the keyboard and mouse need explicit entries too.
  services.usbguard.rules = ''
    # Focusrite Scarlett Solo (3rd Gen) USB audio interface
    allow id 1235:8211 with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 ff:01:20 }
    # ASUS TUF Gaming M4 Air mouse
    allow id 0b05:1a03 with-interface { 03:00:00 03:01:02 03:00:00 }
    # Keychron K2 keyboard (reports as Apple Aluminium Keyboard)
    allow id 05ac:024f with-interface { 03:01:01 03:01:02 }
    # Foxconn/Hon Hai wireless device (onboard Bluetooth radio)
    allow id 0489:e0e2 with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 }
    # ASUS AURA LED controller (onboard RGB)
    allow id 0b05:19af with-interface { ff:ff:ff 03:00:00 }
    # Genesys Logic USB 2.0 hub
    allow id 05e3:0608 with-interface { 09:00:00 }
    # Fosi Audio K5 Pro DAC, downstream of the Genesys hub on port 11-1.1
    allow id 0c76:1700 with-interface { 01:01:00 01:02:00 01:02:00 01:02:00 01:02:00 01:02:00 01:02:00 03:00:00 }
  '';

  host.home-manager.config = {
    imports = [
      inputs.homelab.homeManagerModules.default
    ];

    homelab.ssh_config.enable = true;
  };
}
