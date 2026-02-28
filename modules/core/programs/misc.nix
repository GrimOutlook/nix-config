{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Rust implementations of linux commands
        dust # du
        dysk # df
        duf # df
        procs # ps

        # Other utils
        mprocs
        nixos-anywhere
        wget

        fd
        jq
        ripgrep
      ];

    };
}
