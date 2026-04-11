{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.storage;
in
{
  options.host.default-programs.storage.enable =
    lib.mkEnableOption "Enable default storage programs configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # A minimal, fast alternative to 'du -sh'
      # https://github.com/sharkdp/diskus
      diskus

      # View disk space usage and delete unwanted data, fast.
      # https://github.com/Byron/dua-cli
      dua

      # Rust implementations of linux commands
      dust # du
      dysk # df
      duf # df

      parted

    ];
  };
}
