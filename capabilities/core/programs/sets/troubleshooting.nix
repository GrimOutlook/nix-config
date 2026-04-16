{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.troubleshooting;
in
{
  options.host.default-programs.troubleshooting.enable =
    lib.mkEnableOption "Enable default troubleshooting program set";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Small command-line JSON Log viewer
      # https://github.com/brocode/fblog
      fblog

      # Interactive JSON filter using jq
      # https://github.com/ynqa/jnv
      jnv

      # Logfile Navigator
      # https://github.com/tstack/lnav
      lnav

      # Interactive grep (for streaming)
      # https://github.com/ynqa/sig
      sig

      # A log file highlighter
      # https://github.com/bensadeh/tailspin
      tailspin
    ];

    environment.shellAliases = {
      log = "lnav";
    };
  };
}
