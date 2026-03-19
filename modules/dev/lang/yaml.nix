{
  flake.modules.homeManager.lang_yaml = {
    programs = {
      nixvim = {
        lsp.servers.yamlls.enable = true;
      };
    };
  };
}
