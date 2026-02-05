{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bat # Cat(1) clone with syntax highlighting and Git integration
      ];
      
      environment.variables = {
        MANPAGER = "sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'";
      };

      environment.shellAliases = {
        cat = "bat";
      };
    };
}
