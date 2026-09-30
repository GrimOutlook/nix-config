{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.omo;
in
{
  options.host.dev.ai.omo.enable = lib.mkEnableOption "Enable OmO standalone CLI";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.home.packages =
      with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [ omo-ai ];
  };
}
