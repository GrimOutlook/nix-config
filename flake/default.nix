{
  self,
  inputs,
  nixpkgs,
  ...
}:
{
  flake.modules.default.imports = [
    (inputs.import-tree ./capabilities)
    (inputs.import-tree ./host-types)
  ];

  perSystem =
    {
      self',
      config,
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      # checks.default =
      #   (nixpkgs.lib.nixosSystem {
      #     specialArgs = {
      #       inputs = inputs // {
      #         nix-config.inputs = inputs;
      #       };
      #     };
      #     modules = [
      #       self.nixosModules.default
      #       {
      #         # Required minimal boilerplate
      #         nixpkgs.hostPlatform = system;
      #         boot.loader.grub.enable = false;
      #         fileSystems."/".device = "/dev/nodevice";
      #         host.hostname = "test";
      #       }
      #     ];
      #   }).config.system.build.toplevel;

    };
}
