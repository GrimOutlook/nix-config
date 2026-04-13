{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.lang.dotnet;
in
{
  options.host.lang.dotnet.enable = lib.mkEnableOption "Enable .NET/C# language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config = {
      home.packages = with pkgs; [
        dotnet-sdk_9
        dotnet-runtime_9
        dotnetPackages.Nuget
        csharpier
      ];

      programs.nixvim = {
        lsp.servers.csharp_ls.enable = true;
        plugins = {
          easy-dotnet.enable = true;
          conform-nvim.settings.formatters_by_ft.cs = [ "csharpier" ];
        };
      };
    };
  };
}
