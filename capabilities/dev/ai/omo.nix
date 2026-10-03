{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.dev.ai.omo;
  settingsFormat = pkgs.formats.json { };
  solModel = "chatgpt-subscription/gpt-6.1-sol";
  lunaModel = "chatgpt-subscription/gpt-6-luna";
  lunaFastModel = "chatgpt-subscription/gpt-6-luna-fast";
  candidate = model: reasoning: {
    inherit model reasoning;
  };
  fastModels = [
    (candidate lunaFastModel "low")
    (candidate lunaModel "low")
  ];
  balancedModels = [
    (candidate lunaModel "medium")
    (candidate lunaFastModel "medium")
  ];
  deepModels = [
    (candidate lunaModel "max")
  ];
  highModels = [
    (candidate solModel "high")
  ];
  ultrabrainModels = [
    (candidate solModel "medium")
  ];
  consultantModels = [
    (candidate solModel "medium")
  ];
  visualModels = [
    (candidate lunaModel "max")
    (candidate lunaFastModel "low")
  ];
  creativeModels = [
    (candidate lunaModel "max")
    (candidate lunaFastModel "low")
  ];
  writingModels = [
    (candidate lunaModel "max")
    (candidate lunaFastModel "low")
  ];
in
{
  options.host.dev.ai.omo = {
    enable = lib.mkEnableOption "Enable OmO standalone CLI";

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = {
        defaultProvider = "chatgpt-subscription";
        defaultModel = "gpt-6-luna";
        defaultThinkingLevel = "max";
        modelThinkingLevels = {
          "${lunaModel}" = "max";
          "${lunaFastModel}" = "low";
          "${solModel}" = "medium";
        };
        enabledModels = [
          lunaModel
          lunaFastModel
          solModel
        ];
        favoriteModels = [
          lunaModel
          lunaFastModel
          solModel
        ];
        recommendedModels = [
          "gpt-6-luna"
          "gpt-6-luna-fast"
          "gpt-6.1-sol"
        ];
        retry = {
          modelFallback = true;
          fallbackChains = {
            "${lunaModel}" = [
              "${lunaFastModel}:low"
            ];
          };
        };
      };
      description = "OmO user-wide model defaults, overridden by project .omo/settings.json";
    };

    mcpConfig = lib.mkOption {
      type = settingsFormat.type;
      default = {
        mcpServers.ha-mcp = {
          command = "${pkgs.uv}/bin/uvx";
          args = [ "ha-mcp" ];
          env = {
            HOMEASSISTANT_URL = "\${HOMEASSISTANT_URL}";
            HOMEASSISTANT_TOKEN = "\${HOMEASSISTANT_TOKEN}";
          };
        };
      };
      description = ''
        OmO user-wide MCP servers. Export HOMEASSISTANT_URL and
        HOMEASSISTANT_TOKEN before starting OmO to connect ha-mcp.
        Keep credentials in the runtime environment, not this option.
      '';
    };

    omoConfig = lib.mkOption {
      type = settingsFormat.type;
      default = {
        "$schema" =
          "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json";
        model_profile = lunaModel;
        agents = {
          explore = {
            models = fastModels;
          };
          librarian = {
            models = fastModels;
          };
          plan-consultant = {
            models = consultantModels;
          };
          plan-reviewer = {
            models = highModels;
          };
        };
        categories = {
          architect = {
            models = consultantModels;
          };
          visual-engineering = {
            models = visualModels;
          };
          ultrabrain = {
            models = ultrabrainModels;
          };
          deep-low = {
            models = deepModels;
          };
          deep-high = {
            models = highModels;
          };
          artistry = {
            models = creativeModels;
          };
          quick = {
            models = fastModels;
          };
          unspecified-low = {
            models = balancedModels;
          };
          unspecified-high = {
            models = consultantModels;
          };
          writing = {
            models = writingModels;
          };
        };
      };
      description = "OmO user-wide config, overridden by project .omo/omo.jsonc";
    };
  };

  config = lib.mkIf cfg.enable {
    host.home-manager.config = {
      home.packages =
        with inputs.nix-config.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
          omo-ai
        ];

      # Project .omo/omo.jsonc and .omo/settings.json override these defaults.
      # Senpi replaces settings.json on a saved runtime change, so restore the
      # managed files on the next switch instead of leaving a stale local copy.
      home.file.".omo/omo.jsonc" = {
        source = settingsFormat.generate "omo-config.json" cfg.omoConfig;
        force = true;
      };
      home.file.".omo/agent/settings.json" = {
        source = settingsFormat.generate "omo-settings.json" cfg.settings;
        force = true;
      };
      home.file.".omo/agent/mcp.json" = {
        source = settingsFormat.generate "omo-mcp.json" cfg.mcpConfig;
        force = true;
      };
    };
  };
}
