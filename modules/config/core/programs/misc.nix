{
  flake.modules.homeManager.core =
    { pkgs, ... }:
    {
      programs = {
        bat.enable = true;
        fd.enable = true;
        jq.enable = true;
        ripgrep.enable = true;
      };

      home = {
        packages = with pkgs; [
          # Rust implementations of linux commands
          dust # du
          dysk # df
          duf # df
          procs # ps

          # Other utils
          mprocs
          nixos-anywhere
          wget
        ];
      };
    };
}
