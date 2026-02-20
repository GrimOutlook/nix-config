{inputs, ...}:
{
  flake.modules.homeManager.nh =
    { nhSwitchCommand, ... }:
    {
      home.shellAliases = {
        u = nhSwitchCommand;
        nix-collect-garbage = "echo 'Use `nh clean` instead!'";
      };

      programs.nh = {
        enable = true;

        flake = inputs.flake-source or "";

        clean = {
          enable = true;

          dates = "daily";
          extraArgs = "--keep 1 --keep-since 8d";
        };
      };
    };
}
