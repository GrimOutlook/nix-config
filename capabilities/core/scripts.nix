{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      environment.shellAliases = {
        macs = ''grep -Po "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})"'';
        ips = ''grep -Po "(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}"'';
      };
      environment.systemPackages = with pkgs; [
        (writeShellScriptBin "macvendor" (builtins.readFile ./scripts/macvendor))
        (writeShellScriptBin "certscrape" (builtins.readFile ./scripts/certscrape))
        (writeShellScriptBin "materialize" (builtins.readFile ./scripts/materialize))
        (writeShellScriptBin "cs" (builtins.readFile ./scripts/cs))
        (writeShellScriptBin "acronym" (builtins.readFile ./scripts/acronym))
      ];
    };
}
