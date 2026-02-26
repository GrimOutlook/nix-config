{config, ...}:
{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      programs = {
        nixvim = {
          extraPackages = with pkgs; [
            shellcheck
            shfmt
          ];
          lsp.servers.bashls.enable = true;
        };
      };
    };
}
