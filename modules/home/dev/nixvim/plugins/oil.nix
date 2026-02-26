{config, ...}:
{
  flake.modules.homeManager.dev.programs.nixvim = 
    {pkgs, ...}:
    {
      plugins = {
        oil.enable = true;
        oil-git-status.enable = true;
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Oil<cr>";
          options = {
            desc = "File Explorer";
          };
        }
      ];
    };
}
