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
  primaryModel = "chatgpt-subscription/gpt-6-sol";
  astraModel = "chatgpt-subscription/gpt-6-astra";
  # Mistral exposes only minimal, low, medium, and high for this model.
  glmModel = "mistral/zai-glm-5-3";
  lunaModel = "chatgpt-subscription/gpt-6-luna";
  lunaFastModel = "chatgpt-subscription/gpt-6-luna-fast";
  candidate = model: reasoning: {
    inherit model reasoning;
  };
  fastModels = [
    (candidate lunaFastModel "low")
    (candidate glmModel "low")
    (candidate primaryModel "medium")
  ];
  balancedModels = [
    (candidate lunaModel "medium")
    (candidate glmModel "medium")
    (candidate primaryModel "medium")
  ];
  deepModels = [
    (candidate primaryModel "medium")
    (candidate lunaModel "high")
    (candidate glmModel "high")
  ];
  highModels = [
    (candidate astraModel "xhigh")
    (candidate primaryModel "xhigh")
    (candidate glmModel "high")
    (candidate lunaModel "high")
  ];
  ultrabrainModels = [
    (candidate astraModel "max")
    (candidate primaryModel "max")
    (candidate glmModel "high")
    (candidate lunaModel "high")
  ];
  consultantModels = [
    (candidate glmModel "high")
    (candidate primaryModel "high")
    (candidate lunaModel "high")
  ];
  visualModels = [
    (candidate primaryModel "high")
    (candidate lunaModel "medium")
  ];
  creativeModels = [
    (candidate glmModel "high")
    (candidate primaryModel "high")
    (candidate lunaModel "medium")
  ];
  writingModels = [
    (candidate glmModel "medium")
    (candidate lunaModel "medium")
    (candidate primaryModel "medium")
  ];
in
{
  options.host.dev.ai.omo = {
    enable = lib.mkEnableOption "Enable OmO standalone CLI";

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = {
        defaultProvider = "chatgpt-subscription";
        defaultModel = "gpt-6-sol";
        defaultThinkingLevel = "medium";
        modelThinkingLevels = {
          "${primaryModel}" = "medium";
          "${astraModel}" = "xhigh";
          "${glmModel}" = "high";
          "${lunaModel}" = "medium";
          "${lunaFastModel}" = "low";
        };
        enabledModels = [
          primaryModel
          astraModel
          glmModel
          lunaModel
          lunaFastModel
        ];
        favoriteModels = [
          primaryModel
          astraModel
          glmModel
          lunaModel
          lunaFastModel
        ];
        recommendedModels = [
          "gpt-6-sol"
          "zai-glm-5-3"
          "gpt-6-luna"
        ];
        retry = {
          modelFallback = true;
          fallbackChains = {
            "${primaryModel}" = [
              "${glmModel}:high"
              "${lunaModel}:high"
            ];
          };
        };
      };
      description = "OmO user-wide model defaults, overridden by project .omo/settings.json";
    };

    omoConfig = lib.mkOption {
      type = settingsFormat.type;
      default = {
        "$schema" =
          "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json";
        model_profile = primaryModel;
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
    };
  };
}
