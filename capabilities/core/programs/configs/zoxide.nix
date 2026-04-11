{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.zoxide;
in
{
  options.host.default-program.zoxide.enable =
    lib.mkEnableOption "Enable default zoxide configurations";

  config = lib.mkIf cfg.enable {
    # Fast cd command that learns your habits
    programs.zoxide.enable = true;

    # Disable automatic integration so we can place the eval command at the
    # end ourselves.
    programs.zoxide.enableBashIntegration = false;
    programs.bash.interactiveShellInit = lib.mkOrder 2000 ''
      eval "$(${lib.getExe pkgs.zoxide} init bash)"
    '';

    environment.sessionVariables = {
      _ZO_ECHO = 1;
    };

    environment.shellAliases = {
      cd = "z";
    };
  };
}
