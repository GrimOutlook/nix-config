{
  flake.modules.homeManager.dev =
    {
      pkgs,
      config,
      ...
    }:
    {
      home = {
        packages = with pkgs; [
        ];
      };

      programs = {
        nixvim = {
          lsp.servers = {
            ts_ls.enable = true;
          };
          plugins = {
            package-info = {
              enable = true;
              packageManagerPackage = pkgs.pnpm;
              settings.package_manager = "pnpm";
            };
          };
        };
      };
    };
}
