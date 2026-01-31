{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # TODO: Make `dig` an alias to `dog`
    dogdns # Command-line DNS client
    geoip # API for GeoIP/Geolocation databases
    gping # Ping, but with a graph
    netscanner # Network scanner with features like WiFi scanning, packetdump and more
    ngrep # Network packet analyzer
    # TODO: Make an alias that redirects `nmap` to `rustscan`
    rustcat # Port listener and reverse shell
    rustscan # Faster Nmap Scanning with Rust
  ];

  environment.shellAliases = {
    dig = "dog";
    ping = "gping";
  };
}
