{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.searching;
in
{
  options.host.default-programs.searching.enable =
    lib.mkEnableOption "Enable default searching programs configurations";

  config.environment = lib.mkIf cfg.enable {
    systemPackages = with pkgs; [
      # Greps through binaries from various OSs and architectures, and colors
      # them
      bingrep

      # Simple, fast and user-friendly alternative to find
      fd

      # Much faster locate
      plocate

      # Utility that combines the usability of The Silver Searcher with the
      # raw speed of grep
      ripgrep

      # rga: ripgrep, but also search in PDFs, E-Books, Office documents,
      # zip, tar.gz, etc.
      # https://github.com/phiresky/ripgrep-all
      ripgrep-all
    ];
    shellAliases = {
      todo = "rg TODO";
      td = "rg TODO";
    };
  };
}
