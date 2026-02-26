{
  flake.modules.homeManager.core = {
    home.shellAliases = {
      todo = "rg TODO";
      td = "rg TODO";

      ##################
      # GNU core utils #
      ##################
      c = "cd";
      rm = "rm -iv";
      mkd = "mkdir -pv";
      f = "fg";

      ########
      # Misc #
      ########
      t = "date +'%a %b %e %R:%S %Z %Y'";

      #######
      # Nix #
      #######
      d = "deploy";
      nsp = "nix-shell -p";
      nfu = "nix flake update";
      nfc = "nix flake check";
    };
  };
}
