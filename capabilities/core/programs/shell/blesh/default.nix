{
  flake.modules.nixos.core =
    { pkgs, lib, ... }:
    {
      environment.etc."blerc".text = builtins.readFile ./blerc + builtins.readFile ./ble-keybinds;

      programs.bash = {
        # Don't use blesh.enable - it loads ble.sh BEFORE bash-completion
        # which breaks git completions. Instead, we manually attach ble.sh
        # AFTER bash-completion has loaded using promptPluginInit with mkAfter.
        promptPluginInit = lib.mkAfter ''
          source ${pkgs.blesh}/share/blesh/ble.sh
          source /etc/blerc
        '';
      };
    };
}
