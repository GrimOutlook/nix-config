{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      system,
      lib,
      ...
    }:
    {
      checks.devshells = pkgs.symlinkJoin {
        name = "devshells-checks";
        paths = lib.attrValues config.devShells;
      };

      devshells.default = {
        commands = [
          {
            name = "update";
            command = ''
              echo "=> Updating flake inputs"
              nix flake update

              nix flake check

              git add flake.lock
              git commit -m "flake.lock: Update"
              git push
            '';
            help = "Update all flakes + commit and push";
          }
          {
            name = "unlink-results";
            # packages = [ "fd" ];
            command = ''
              ${lib.getExe pkgs.fd} --no-ignore --max-depth 1 'result*' --exec unlink
            '';
            help = "Unlink all `result` symlinks";
          }
        ];
      };
    };
}
