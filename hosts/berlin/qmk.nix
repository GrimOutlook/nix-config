{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    qmk
    qmk_hid
  ];
  services.udev.packages = with pkgs; [
    qmk-udev-rules
  ];
}
