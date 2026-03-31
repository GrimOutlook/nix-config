{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Rust implementations of linux commands
        dust # du
        dysk # df
        duf # df

        parted

      ];
    };
}
