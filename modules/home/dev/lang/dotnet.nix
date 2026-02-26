{ lib, ... }:
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
          dotnet-sdk_9
          dotnet-runtime_9
          dotnetPackages.Nuget
          csharpier
        ];
      };

      programs = {
        nixvim = {
          lsp.servers = {
            csharp_ls.enable = true;
          };
          plugins = {
            easy-dotnet.enable = true;
            conform-nvim = {
              settings = {
                formatters_by_ft = {
                  cs = [ "csharpier" ];
                };
              };
            };
          };
        };
      };
    };
}
