{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.nerd-fonts;
in
{
  options.host.nerd-fonts.enable = lib.mkEnableOption "Enable nerd fonts";

  config = lib.mkIf cfg.enable {
    fonts.packages =
      with pkgs.nerd-fonts;
      [
        jetbrains-mono
        iosevka-term
      ]
      ++ (with pkgs; [
        noto-fonts-color-emoji
        font-awesome
      ]);
  };
}
