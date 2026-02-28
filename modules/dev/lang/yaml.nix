{
  flake.modules.homeManager.dev = {
    programs = {
      nixvim = {
        lsp.servers.yamlls.enable = true;
      };
    };
  };
}
