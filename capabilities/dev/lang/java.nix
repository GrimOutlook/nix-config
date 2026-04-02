{
  flake.modules.homeManager.lang_java =
    { pkgs, ... }:
    {
      programs = {
        nixvim = {
          lsp.servers.jdtls.enable = true;
          plugins = {
            # jdtls.enable = true;
            conform-nvim = {
              settings = {
                formatters_by_ft = {
                  javA = [ "google-java-format" ];
                };
              };
            };
          };
        };
      };
      home = {
        packages = with pkgs; [
          google-java-format
        ];
      };
    };
}
