{ pkgs, ... }:
{
  host.home-manager.config.home.packages = with pkgs; [
    prusa-slicer
    orca-slicer
  ];
}
