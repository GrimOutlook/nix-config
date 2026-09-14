{
  config,
  lib,
  ...
}:
let
  cfg = config.host.firefox;
in
{
  options.host.firefox.enable = lib.mkEnableOption "Enable Firefox";

  config = lib.mkIf cfg.enable {
    host.nix.realtimePackages = [ "firefox" ];

    programs.firefox = {
      enable = true;

      policies = {
        # Performance and security basics
        AppAutoUpdate = false;
        HardwareAcceleration = true;
        CaptivePortal = false;

        # Privacy: Disable telemetry and data collection
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;

        # UI and Behavior customization
        DontCheckDefaultBrowser = true;
        DisableSetDesktopBackground = true;
        Certificates.EnterpriseRoots = true;
        MicrosoftEntraSSO = true;
        WindowsSSO = true;

        # Clean up the "New Tab" page
        FirefoxHome = {
          Search = false;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
        };

        # Disable onboarding and recommendations
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };

        # Declaratively installed add-ons. Firefox fetches each XPI from AMO on
        # first run (so versions are not pinned by the flake); everything not
        # listed here is blocked from installing.
        ExtensionSettings = {
          "*".installation_mode = "blocked";

          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };

          "addon@darkreader.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
          };

          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };

          # Overlaps with the native `privacy.query_stripping` prefs below;
          # ClearURLs covers more rules but does so by injecting into pages.
          "{74145f27-f039-47ce-a470-a662b129930a}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
            installation_mode = "force_installed";
          };

          "firefox-extension@steamdb.info" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/steam-database/latest.xpi";
            installation_mode = "force_installed";
          };

          "{6b733b82-9261-47ee-a595-2dda294a4d08}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/yomitan/latest.xpi";
            installation_mode = "force_installed";
          };

          "sponsorBlocker@ajay.app" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        DisableAppUpdate = true;
        OverrideFirstRunPage = "";
        PictureInPicture.Enabled = false;
        PromptForDownloadLocation = false;

        # Low-level preference overrides
        Preferences = {
          "widget.use-xdg-desktop-portal.file-picker" = 1; # Use system file picker
          "browser.tabs.loadInBackground" = true;
          "media.ffmpeg.vaapi.enabled" = true; # Enable hardware video acceleration
          "browser.aboutConfig.showWarning" = false;
          "browser.warnOnQuitShortcut" = true;
          # Strip the common tracking params (utm_*, fbclid, gclid, ...)
          # natively, so the cheap cases never need a content script.
          # ClearURLs (see ExtensionSettings above) handles the long tail.
          "privacy.query_stripping.enabled" = true;
          "privacy.query_stripping.enabled.pbmode" = true;
        };

        PopupBlocking = {
          Default = false;
          Locked = true;
        };

        # Privacy: Disable address bar suggestions
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };
      };
    };

    # Enable Geoclue2 and permit Firefox to access location information.
    services.geoclue2 = {
      enable = lib.mkDefault true;
      appConfig.firefox = {
        desktopID = "firefox.desktop";
        isAllowed = true;
      };
    };
  };
}
