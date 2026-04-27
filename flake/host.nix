{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options = {
    host = mkOption {
      type =
        with types;
        attrsOf (
          submodule (
            { name }:
            {
              options = {
                name = mkOption {
                  type = types.str;
                  default = name;
                  description = "Hostname of the host";
                };
                config = mkOption {
                  type = types.deferredModule;
                  default = { };
                  description = "nixos configurations that are passed to `nixosConfigurations.\${hostname}`";
                };
              };
            }
          )
        );
      default = { };
      description = "Host definition";
    };
  };
}
