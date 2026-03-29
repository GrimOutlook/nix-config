{
  flake.modules.nixos.build-arm = {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
}
