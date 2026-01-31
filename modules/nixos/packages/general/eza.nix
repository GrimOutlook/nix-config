{ inputs, lib, config, pkgs, ... }:


let
  EZA_DEFAULT_OPTIONS="--header --long --time-style long-iso --git-repos --git --icons --octal-permissions --classify --hyperlink --group --mounts --extended";
in
{
  environment.systemPackages = with pkgs; [
    eza # Modern, maintained replacement for ls
  ];
  
  environment.shellAliases = {
    l = "eza ${EZA_DEFAULT_OPTIONS}";
    ls = "eza ${EZA_DEFAULT_OPTIONS}";
    la = "eza -a ${EZA_DEFAULT_OPTIONS}";
    lr = "eza -R ${EZA_DEFAULT_OPTIONS}";
    lsr = "eza -R ${EZA_DEFAULT_OPTIONS}";
    lar = "eza -Ra ${EZA_DEFAULT_OPTIONS}";
    lt = "eza -R --tree ${EZA_DEFAULT_OPTIONS}";
  };
}
