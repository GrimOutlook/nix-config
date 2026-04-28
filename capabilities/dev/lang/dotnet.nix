{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.lang.dotnet;
in
{
  options.host.dev.lang.dotnet.enable = lib.mkEnableOption "Enable .NET/C# language support";

  config.host.home-manager.config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
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
}
