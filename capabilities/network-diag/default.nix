{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.network-diag;
in
{
  options.host.network-diag.enable = lib.mkEnableOption "Enable network diag configurations";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.home = {
      packages = with pkgs; [
        # A fast, simple, recursive content discovery tool written in Rust.
        # https://github.com/epi052/feroxbuster
        feroxbuster

        # API for GeoIP/Geolocation databases
        # https://www.maxmind.com/
        geoip

        # An interactive TLS-capable intercepting HTTP proxy for penetration
        # testers and software developers.
        # https://github.com/mitmproxy/mitmproxy
        mitmproxy

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

        # A terminal UI for tshark, inspired by Wireshark
        # https://github.com/gcla/termshark
        termshark

        # A network diagnostic tool
        # https://github.com/fujiapple852/trippy
        trippy
      ];
      shellAliases = {
        nc = "rcat";
        netcat = "rcat";
        scan = "rustscan";
        wireshark = "termshark";
      };
    };
  };
}
