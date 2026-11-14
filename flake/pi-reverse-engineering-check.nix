{ self, ... }:
let
  configuration =
    enabled:
    (self.nixosConfigurations.example.extendModules {
      modules = [
        {
          host.dev.ai.pi.enable = true;
          host.dev.ai.pi.reverseEngineering.enable = enabled;
        }
      ];
    }).config.home-manager.users.owner.home;
  enabled = configuration true;
  disabled = configuration false;
  servers =
    (builtins.fromJSON (builtins.unsafeDiscardStringContext enabled.file.".pi/agent/mcp.json".text))
    .mcpServers;
in
{
  perSystem = { pkgs, ... }: {
    checks.pi-reverse-engineering =
      assert
        builtins.attrNames servers == [
          "ghidra"
          "radare2"
        ];
      assert
        servers.ghidra.args == [
          "--ghidra-server"
          "http://127.0.0.1:8080/"
        ];
      assert !(disabled.file ? ".pi/agent/mcp.json");
      pkgs.runCommand "pi-reverse-engineering-config" { } ''
        touch "$out"
      '';
  };
}
