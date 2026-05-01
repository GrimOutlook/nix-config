{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.nixvim.plugins.fyler;
in
{
  options.host.dev.nixvim.plugins.fyler.enable = lib.mkEnableOption "Enable nixvim fyler plugin";

  config.host.home-manager.config.programs.nixvim = lib.mkIf cfg.enable {
    extraPlugins = with pkgs.vimPlugins; [
      fyler-nvim
    ];

    extraConfigLua = ''
      require('fyler').setup()
    '';

    keymaps = [
      {
        mode = [
          "n"
        ];
        key = "<leader>e";
        action = "<CMD>Fyler kind=split_left_most<CR>";
        options = {
          desc = "Open Fyler Panel";
        };
      }
    ];
  };
}
