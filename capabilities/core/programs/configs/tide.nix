{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.tide;
  tideInitScript = ''
    # Default Tide prompt configuration if not already configured
    set -q tide_left_prompt_items || set -g tide_left_prompt_items pwd git newline character
    set -q tide_right_prompt_items || set -g tide_right_prompt_items status cmd_duration context jobs direnv node python rustc go nix_shell
    set -q tide_character_icon || set -g tide_character_icon "❯"
    set -q tide_character_color || set -g tide_character_color green
    set -q tide_character_color_failure || set -g tide_character_color_failure red
    set -q tide_pwd_color_anchors || set -g tide_pwd_color_anchors cyan
    set -q tide_pwd_color_dirs || set -g tide_pwd_color_dirs blue
    set -q tide_pwd_color_truncated_dirs || set -g tide_pwd_color_truncated_dirs brblack
  '';
in
{
  options.host.default-program.tide.enable =
    lib.mkEnableOption "Enable default tide fish plugin configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fishPlugins.tide
    ];

    programs.fish.interactiveShellInit = tideInitScript;

    host.home-manager.config.programs.fish = {
      plugins = [
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
      ];
      interactiveShellInit = tideInitScript;
    };
  };
}
