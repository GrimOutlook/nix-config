{
  config,
  lib,
  ...
}:
let
  cfg = config.host.default-programs.nixvim.plugins.oil;
in
{
  options.host.default-programs.nixvim.plugins.oil.enable =
    lib.mkEnableOption "Enable nixvim oil plugin";

  config.host.home-manager.config.programs.nixvim = lib.mkIf cfg.enable {
    plugins = {
      oil-git-status.enable = true;
      oil.enable = true;
    };

    keymaps = [
      {
        mode = [
          "n"
        ];
        key = "<leader>e";
        action = "<CMD>Oil<CR>";
        options = {
          desc = "File Explorer";
        };
      }
    ];
  };
}
