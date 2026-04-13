{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.lang.typescript;
in
{
  options.host.lang.typescript.enable = lib.mkEnableOption "Enable TypeScript language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim = {
      lsp.servers.ts_ls.enable = true;
      plugins.package-info = {
        enable = true;
        packageManagerPackage = pkgs.pnpm;
        settings.package_manager = "pnpm";
      };
    };
  };
}
