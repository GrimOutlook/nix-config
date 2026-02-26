{
  flake.modules.homeManager.dev.programs.nixvim = 
    {pkgs, ...}:
    {
      plugins.snacks = {
        enable = true;
        settings.which-key = {
          enable = true;
          preset = "helix";
        };
      };
    };
}
