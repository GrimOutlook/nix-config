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

              deploy

              git add flake.lock
              git commit -m "flake.lock: Update"
              git push
            '';
          }
          {
            name = "rebuild";
            command = ''
              hostname=$1
              [ -z "$hostname" ] && hostname=$(hostname)

              echo "=> Deploying system '$hostname'"
              nh os switch . \
                  --hostname $hostname \
                  --target-host root@$hostname \
                  --build-host root@$hostname
            '';
          }
          {
            name = "unlink-results";
            # packages = [ "fd" ];
            command = ''
              ${lib.getExe pkgs.fd} --no-ignore --max-depth 1 'result*' --exec unlink
            '';
          }
        ];
      };
    };
}
