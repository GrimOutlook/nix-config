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

  # NOTE: gate the whole `host.home-manager.config` definition, not the value
  # inside it. When nixvim is disabled its home-manager module is never
  # imported, so a `mkIf false` nested *under* `programs.nixvim` would still be
  # a definition of an option that does not exist, and evaluation fails.
  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim = {
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
  };
}
