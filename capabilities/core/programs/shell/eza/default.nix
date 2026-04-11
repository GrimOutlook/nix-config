{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.eza;
in
{
  options.host.default-program.eza.enable = lib.mkEnableOption "Enable default eza configurations";

  config =
    let
      eza_config_file = ./theme.yml;
      # Add a timeout for large or non-responsive directories
      EZA_DEFAULT_OPTIONS = "timeout --kill-after=4s 3s eza --header --long --time-style long-iso --git-repos --git --icons --octal-permissions --classify --hyperlink --group --mounts --extended";
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        eza
      ];
      environment.shellAliases = {
        l = EZA_DEFAULT_OPTIONS;
        ls = EZA_DEFAULT_OPTIONS;
        la = "${EZA_DEFAULT_OPTIONS} -a";
        lr = "${EZA_DEFAULT_OPTIONS} -R";
        lsr = "${EZA_DEFAULT_OPTIONS} -R";
        lar = "${EZA_DEFAULT_OPTIONS} -Ra";
        lt = "${EZA_DEFAULT_OPTIONS} -R --tree";
      };

      environment.etc."eza/config.yml" = {
        source = eza_config_file;
      };

      environment.sessionVariables = {
        EZA_CONFIG_DIR = builtins.dirOf eza_config_file;
      };
    };
}
