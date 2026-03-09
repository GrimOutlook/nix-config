{
  flake.modules.nixos.bluetooth =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bluetui
        bluez
      ];
      hardware.bluetooth.enable = true;
    };
}
