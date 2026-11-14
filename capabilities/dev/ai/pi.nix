{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.pi;
  reverseEngineering = import ./_reverse-engineering.nix { inherit pkgs lib; };
  permissionReviewer = import ./_permission-reviewer.nix { inherit inputs pkgs; };
in
{
  options.host.dev.ai.pi = {
    enable = lib.mkEnableOption "Enable Pi CLI configuration";
    reverseEngineering.enable =
      lib.mkEnableOption "the reverse-engineering toolkit and Pi MCP servers"
      // {
        default = true;
      };
    permissionReviewer = {
      enable = lib.mkEnableOption "the Pi tool-call permission reviewer" // {
        default = true;
      };
      escalationMode = lib.mkOption {
        type = lib.types.enum [
          "manual"
          "deny"
        ];
        default = "manual";
        description = "Ask for human approval of questionable calls, or deny them with reasoning.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    host.home-manager.config.home = {
      packages = [
        inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
        (pkgs.writeShellScriptBin "pi-browser" ''
          profile="''${XDG_CONFIG_HOME:-$HOME/.config}/pi-browser"
          exec ${pkgs.chromium}/bin/chromium \
            --remote-debugging-address=127.0.0.1 \
            --remote-debugging-port=9222 \
            --user-data-dir="$profile" \
            "$@"
        '')
      ]
      ++ lib.optionals cfg.reverseEngineering.enable reverseEngineering.packages;
      sessionVariables.NODE_USE_SYSTEM_CA = "1";
      file = {
        ".pi/agent/mcp.json".text = builtins.toJSON {
          mcpServers = lib.optionalAttrs cfg.reverseEngineering.enable reverseEngineering.mcpServers // {
            playwright = {
              command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
              args = [
                "--cdp-endpoint"
                "http://127.0.0.1:9222"
              ];
              description = "Control the logged-in Chromium browser started with pi-browser over local CDP.";
            };
          };
        };
        ".pi/agent/settings.json".text = builtins.toJSON {
          defaultProvider = "openai";
          defaultModel = "gpt-6.1-sol";
          defaultThinkingLevel = "low";
        };
        # An explicit extension directory loads only the Pi entry, not the
        # OpenCode plugin/TUI entries shipped in the same package.
        ".pi/agent/extensions/permission-reviewer/index.js" = lib.mkIf cfg.permissionReviewer.enable {
          source = "${permissionReviewer}/dist/pi.js";
        };
        ".pi/agent/permission-reviewer.json" = lib.mkIf cfg.permissionReviewer.enable {
          text = builtins.toJSON {
            # Omit model to use Pi's selected model and authentication.
            variant = "low";
            timeoutMs = 60000;
            audit = true;
            escalationMode = cfg.permissionReviewer.escalationMode;
          };
        };
      };
    };
  };
}
