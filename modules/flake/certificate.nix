{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}@flakeArgs:
{
  flake.modules.nixos.agenix =
    { config, pkgs, ... }:
    let
      certificates = config.services.import-certificates;
    in
    {
      options.services.import-certificates = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = "Extra certificates to trust";
      };

      config = lib.mkIf (certificates != [ ]) {
        environment.systemPackages = [
          pkgs.cacert # Bundle of X.509 certificates of public Certificate Authorities (CA)
        ];
        security.pki.certificateFiles = [
          "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        ]
        ++ map (file: pkgs.runCommand "copy-certificate-${file}" { } "cp ${file} $out") certificates;
      };
    };
}
