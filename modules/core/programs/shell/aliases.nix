{
  flake.modules.nixos.core = {
    environment.shellAliases = {
      todo = "rg TODO";
      td = "rg TODO";

      ##################
      # GNU core utils #
      ##################
      rm = "rm -iv";

      ########
      # Misc #
      ########
      t = "date +'%a %b %e %R:%S %Z %Y'";
    };
  };
}
