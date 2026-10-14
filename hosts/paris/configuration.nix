{
  inputs,
  pkgs,
  ...
}:
{

  host.hostname = "paris";
  host = {
    bluetooth.enable = true;
    build-arm.enable = true;
    dev.enable = true;
    dev.embedded.enable = true;
    dev.lang.nix.enable = true;
    dev.lang.python.enable = true;
    dev.lang.rust.enable = true;
    dev.lang.typescript.enable = true;
    network-diag.enable = true;
    type.laptop.enable = true;
    virtualization.enable = true;
  };

  environment.systemPackages = with pkgs; [
    chromium
    keepassxc
    qmk
    qmk_hid
    kdePackages.kdenlive
  ];
  services.udev.packages = with pkgs; [
    qmk-udev-rules
  ];
  # Cisco USB console cable, for switch/router console access
  services.usbguard.rules = ''
    # Intel AX201 onboard Bluetooth adapter
    allow id 8087:0026
    # Phone
    allow id 18d1:4ee7
    allow id 05a6:0009 with-interface { 02:02:01 0a:00:00 }
  '';
  programs = {
    steam.enable = true;
    # gamemode = {
    #   enable = true;
    #   enableRenice = true;
    # };
    nix-ld.enable = true;

    thunderbird.enable = true;
  };

  host.home-manager.config = {
    imports = [
      inputs.homelab.homeManagerModules.default
    ];
    homelab.ssh_config.enable = true;
    home = {
      packages = with pkgs; [
        obsidian
        orca-slicer
        prusa-slicer
      ];
    };
  };
}
