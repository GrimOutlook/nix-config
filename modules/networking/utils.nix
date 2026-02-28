{
  flake.modules.homeManager.networking =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        # API for GeoIP/Geolocation databases
        # https://www.maxmind.com/
        geoip

        # Network scanner with features like WiFi scanning, packetdump and more
        # https://github.com/Chleba/netscanner
        netscanner

        # Free and open source utility for network discovery and security auditing
        # http://www.nmap.org/
        nmap

        # Network packet analyzer
        # https://github.com/jpr5/ngrep/
        ngrep # Network packet analyzer

        # Port listener and reverse shell
        # https://github.com/robiot/rustcat
        rustcat

        # TODO: Not currently in nixpkgs repo
        # # A cross-platform network monitoring terminal UI tool built with Rust.
        # # https://github.com/domcyrus/rustnet
        # rustnet

        # The Modern Port Scanner.
        # https://github.com/bee-san/RustScan
        # NOTE: Still need `nmap` for deep inspection since this tool only does
        # port scans.
        rustscan
      ];

      home.shellAliases = {
        nc = "rcat";
        netcat = "rcat";
        scan = "rustscan";
      };
    };
}
