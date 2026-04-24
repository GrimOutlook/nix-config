{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.github-cli;
in
{
  options.host.dev.github-cli.enable = lib.mkEnableOption "Enable github-cli configuration";

  config.host.home-manager.config = lib.mkIf cfg.enable {
    programs.gh = {
      enable = true;

      settings.git_protocol = "ssh";
    };
  };
}
