{ self, ... }:
let
  enabled =
    (self.nixosConfigurations.example.extendModules {
      modules = [ { host.dev.ai.pi.enable = true; } ];
    }).config;
  disabled =
    (self.nixosConfigurations.example.extendModules {
      modules = [
        {
          host.dev.ai.pi.enable = true;
          host.dev.ai.pi.permissionReviewer.enable = false;
        }
      ];
    }).config;
  enabledFiles = enabled.home-manager.users.owner.home.file;
  disabledFiles = disabled.home-manager.users.owner.home.file;
  reviewerConfig = builtins.fromJSON enabledFiles.".pi/agent/permission-reviewer.json".text;
in
{
  perSystem = { pkgs, ... }: {
    checks.pi-permission-reviewer =
      assert enabled.host.dev.ai.pi.permissionReviewer.enable;
      assert enabledFiles ? ".pi/agent/extensions/permission-reviewer/index.js";
      assert reviewerConfig.escalationMode == "manual";
      assert reviewerConfig.audit;
      assert !(reviewerConfig ? model);
      assert !(disabledFiles ? ".pi/agent/extensions/permission-reviewer/index.js");
      assert !(disabledFiles ? ".pi/agent/permission-reviewer.json");
      pkgs.runCommand "pi-permission-reviewer-config" { } ''
        touch "$out"
      '';
  };
}
