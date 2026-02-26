{
  flake.modules.homeManager.dev = {
    programs = {
      nixvim = {
        lsp.servers.tombi.enable = true;
      };
    };
  };
}
