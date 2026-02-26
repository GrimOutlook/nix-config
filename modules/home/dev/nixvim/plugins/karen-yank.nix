{ inputs, ... }:
{
  flake.modules.homeManager.dev.programs.nixvim =
    { pkgs, ... }:
    {
      extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "karen-yank-nvim";
          version = "unstable";
          src = inputs.karen-yank-nvim;
        })
      ];
      extraConfigLua = ''
        require('karen-yank').setup({})
      '';
    };
}
