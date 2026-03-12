{
  flake.modules.nixos.core =
    { nhFlake, ... }:
    {
      environment = {
        shellAliases = {
          u = "nh os switch";
          nix-collect-garbage = "echo 'Use `nh clean` instead!'";
        };
        sessionVariables = {
          NH_FLAKE = nhFlake;
        };
      };

      programs.nh = {
        enable = true;

        flake = nhFlake;

        clean = {
          enable = true;

          dates = "daily";
          extraArgs = "--keep 5 --keep-since 8d";
        };
      };
    };
}
