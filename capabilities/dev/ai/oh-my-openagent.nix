{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.oh-my-openagent;
in
{
  options.host.dev.ai.oh-my-openagent = {
    enable = lib.mkEnableOption "Enable oh-my-openagent configuration";

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = (pkgs.formats.json { }).type;
      };
      default = { };
      description = "Settings for oh-my-openagent written to ~/.omo/omo.jsonc";
    };
  };

  config = lib.mkIf cfg.enable {
    host.dev.ai.oh-my-openagent.settings = {
      team_mode = {
        enabled = lib.mkDefault true;
        max_parallel_members = lib.mkDefault 4;
        max_members = lib.mkDefault 8;
        tmux_visualization = lib.mkDefault false;
      };
    };

    host.home-manager.config = {
      home = {
        file = {
          ".omo/omo.jsonc" = {
            text = builtins.toJSON cfg.settings;
            force = true;
          };
          ".omo/omo.json" = {
            text = builtins.toJSON cfg.settings;
            force = true;
          };
        };
        packages =
          with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
            oh-my-opencode
          ];
      };
    };
  };
}
