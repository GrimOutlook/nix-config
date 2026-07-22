{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.opencode;
in
{
  options.host.dev.ai.opencode.enable =
    lib.mkEnableOption "Enable OpenCode CLI configuration";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.home.packages =
      with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        opencode
      ];
  };
}
