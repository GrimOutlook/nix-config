{
  flake.modules.homeManager.nh =
    { nhFlake, ... }:
    {
      home.shellAliases = {
        u = "nh os switch";
        nix-collect-garbage = "echo 'Use `nh clean` instead!'";
      };

      programs.nh = {
        enable = true;

        flake = nhFlake;

        clean = {
          enable = true;

          dates = "daily";
          extraArgs = "--keep 1 --keep-since 8d";
        };
      };
    };
}
