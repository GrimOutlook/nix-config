{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.tide;
  tideInitScript = ''
    # Initialize Tide's color scheme, icons, and other cosmetic settings once.
    # This only sets the prompt item lists as a side effect, so they're
    # pinned explicitly below regardless of whether this runs.
    if not set -q tide_left_prompt_items
        tide configure --auto --style=Lean --prompt_colors="True color" --show_time=No --lean_prompt_height="Two lines" --prompt_connection_andor_frame_color="Light" --prompt_spacing=Compact --icons="Few icons" --transient=No >/dev/null 2>&1
    end

    # Unconditionally pin the full prompt item lists so a partial/stale
    # universal variable (e.g. left over from a manual `tide configure` run
    # predating this module) can never leave the prompt half-populated.
    set -U tide_context_always_display true
    set -U tide_left_prompt_items context pwd git newline character
    set -U tide_right_prompt_items status cmd_duration jobs direnv bun node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig
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
