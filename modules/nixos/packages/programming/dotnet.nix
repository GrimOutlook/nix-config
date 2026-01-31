{ inputs, lib, config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dotnet-sdk
    dotnet-runtime
    pkgs.dotnetPackages.Nuget
  ];
}
