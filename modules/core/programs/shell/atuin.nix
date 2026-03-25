{
  flake.modules.nixos.core =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Replacement for a shell history which records additional commands
        # context with optional encrypted synchronization between machines
        # https://github.com/atuinsh/atuin
        atuin
      ];

      programs.bash.interactiveShellInit = lib.mkOrder 1900 ''
        eval "$(atuin init bash)"
      '';
    };
}
