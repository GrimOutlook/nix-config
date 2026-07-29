{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.tide;
  tideInitScript = ''
    if not set -q tide_left_prompt_items
      # --lean_prompt_height="Two lines" leads to the 'prompt_connection'
      # choice (not just 'prompt_connection_andor_frame_color'); without an
      # answer for it, --auto bails with "Missing input for choice
      # 'prompt_connection'" and none of the defaults below get set, since
      # stderr is discarded.
      tide configure --auto --style=Lean --prompt_colors="True color" --show_time=No --lean_prompt_height="Two lines" --prompt_connection="Disconnected" --prompt_connection_andor_frame_color="Light" --prompt_spacing=Compact --icons="Few icons" --transient=No >/dev/null 2>&1

      # Pin the full prompt item lists so they always include context on the
      # left (deduped off the right) regardless of what `configure --auto`
      # produced.
      set -U tide_context_always_display true
      set -U tide_left_prompt_items context pwd git newline character
      set -U tide_right_prompt_items status cmd_duration jobs direnv bun node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig
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
