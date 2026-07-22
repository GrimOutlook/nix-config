{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.opencode;
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    disabled_providers = [ "opencode" ];
    share = "disabled";
    mcp = {
      nixos = {
        enabled = true;
        type = "local";
        command = "nix run github:utensils/mcp-nixos --";
      };
    };
  };
in
{
  options.host.dev.ai.opencode.enable =
    lib.mkEnableOption "Enable OpenCode CLI configuration";

  config = lib.mkIf cfg.enable {
    host.home-manager.config = {
      home = {
        file.".config/opencode/opencode.json" = {
          text = lib.mkDefault (builtins.toJSON opencodeConfig);
          force = true;
        };
        packages =
          with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
            opencode
          ];
      };
    };
  };
}
