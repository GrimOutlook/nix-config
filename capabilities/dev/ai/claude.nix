{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.claude;
in
{
  options.host.dev.ai.claude.enable =
    lib.mkEnableOption "Enable Claude Code CLI configuration";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.home.packages =
      with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        claude-code
      ];
  };
}
