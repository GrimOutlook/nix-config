{ inputs, ... }:
{
  flake.modules.homeManager.agenix =
    { config, configName, ... }:
    {
      imports = [
        inputs.agenix.homeManagerModules.default
      ];
    };
}
