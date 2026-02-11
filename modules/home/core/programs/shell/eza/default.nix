{
  flake.modules.homeManager.core =
    { config, pkgs, ... }:

    let
      eza_config_file = ./theme.yml;
      EZA_DEFAULT_OPTIONS="--header --long --time-style long-iso --git-repos --git --icons --octal-permissions --classify --hyperlink --group --mounts --extended";
    in
    {
      # Modern, maintained replacement for ls
      programs.eza = {
        enable = true;
        enableBashIntegration = true;
      };
      
      home.shellAliases = {
        l = "eza ${EZA_DEFAULT_OPTIONS}";
        ls = "eza ${EZA_DEFAULT_OPTIONS}";
        la = "eza -a ${EZA_DEFAULT_OPTIONS}";
        lr = "eza -R ${EZA_DEFAULT_OPTIONS}";
        lsr = "eza -R ${EZA_DEFAULT_OPTIONS}";
        lar = "eza -Ra ${EZA_DEFAULT_OPTIONS}";
        lt = "eza -R --tree ${EZA_DEFAULT_OPTIONS}";
      };

      home.file.".config/eza/config.yml" = {
        source = eza_config_file;
      };

      home.sessionVariables = {
        EZA_CONFIG_DIR = builtins.dirOf eza_config_file;
      };
    };
}
