{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.nix-config.inputs.look.nixosModules.default ];

  options.host.look.enable = lib.mkEnableOption "Enable the Look launcher";

  config = lib.mkIf config.host.look.enable {
    programs.lookapp.enable = true;
  };
}
