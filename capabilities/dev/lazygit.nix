{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.lazygit;
in
{
  options.host.dev.lazygit.enable = lib.mkEnableOption "Enable lazygit configuration";

  config.host.home-manager.config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        gui.theme = {
          activeBorderColor = [
            "blue"
            "bold"
          ];
          selectedLineBgColor = [ "white" ];
        };

        git = {
          # Improves performance
          # https://github.com/jesseduffield/lazygit/issues/2875#issuecomment-1665376437
          log.order = "default";

          fetchAll = false;
        };
      };
    };
  };
}
