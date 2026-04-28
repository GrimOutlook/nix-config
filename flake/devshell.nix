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
            name = "switch";
            command = ''
              hostname=''${1:-""}

              base_command='nh os switch . --hostname $hostname'

              if [ -z "$hostname" ]; then
                configs=$(
                  nix eval .#nixosConfigurations --apply 'builtins.attrNames' --json |
                  jq '[ .[] | select(. != "default") ]'
                )
                case "$(jq 'length' <<< $configs)" in
                  0) 
                    echo "No hostname found. Building default and switching locally..."
                    hostname="default"
                    command="$base_command"
                    ;;
                  1)
                    hostname=$(jq '.[0]' <<< "$configs")
                    command="$base_command" '--target-host root@$hostname --build-host root@$hostname'
                    ;;
                  *)
                    echo "Failed to get hostname to build from flake.nix. Available hosts: $configs" >&2
                    exit 1
                    ;;
                esac
              fi

              echo "=> Deploying system '$hostname'"
              eval "$command"
            '';
            help = "Rebuild nix configuration for host";
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
