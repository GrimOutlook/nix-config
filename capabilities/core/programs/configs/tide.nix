{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.tide;
  tideInitScript = ''
    # Initialize Tide default configuration if not already configured
    if not set -q tide_left_prompt_items
        tide configure --auto --style=Lean --prompt_colors="True color" --show_time=No --lean_prompt_height="One line" --prompt_connection_andor_frame_color="Light" --prompt_spacing=Compact --icons="Few icons" --transient=No >/dev/null 2>&1
    end
    set -U tide_context_always_display true
    if not contains context $tide_left_prompt_items
        set -U tide_left_prompt_items context $tide_left_prompt_items
    end
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
