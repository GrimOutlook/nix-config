{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    gpu-screen-recorder-gtk
  ];
  programs.gpu-screen-recorder.enable = true;
}
