{
  flake.modules.homeManager.lang_toml = {
    programs = {
      nixvim = {
        lsp.servers.tombi.enable = true;
      };
    };
  };
}
