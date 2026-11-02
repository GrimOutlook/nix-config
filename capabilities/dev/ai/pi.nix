{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.pi;
in
{
  options.host.dev.ai.pi.enable = lib.mkEnableOption "Enable Pi CLI configuration";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.home = {
      packages = [
        inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
      ];
      sessionVariables.NODE_USE_SYSTEM_CA = "1";
      file.".pi/agent/settings.json".text = builtins.toJSON {
        defaultProvider = "openai";
        defaultModel = "gpt-6.1-sol";
        defaultThinkingLevel = "low";
      };
    };
  };
}
