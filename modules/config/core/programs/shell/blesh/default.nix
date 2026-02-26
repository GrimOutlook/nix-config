{
  flake.modules.nixos.dev = {
    environment.etc."blerc".text = builtins.readFile ./blerc + builtins.readFile ./ble-keybinds;

    programs.bash = {
      blesh.enable = true;
      interactiveShellInit = "source /etc/blerc";
    };
  };
}
