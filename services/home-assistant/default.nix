{
  fragments,
  homeSettings,
  trustedProxies,
  extraModules,
  componentSources,
  quietDeviceAddress,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Home Assistant itself comes from this image, not nixpkgs (see the
  # container below), so this tag -- not flake.lock -- is what pins and
  # upgrades it. The custom components below have minimum versions; check
  # them when bumping this.
  homeAssistantImage = "ghcr.io/home-assistant/home-assistant:2026.9.4";
  # Major versions migrate the config entry one way (4.x -> 6.0 did both the
  # 5.0 and 6.0 migrations); read the upgrade guide in
  # github.com/raman325/lock_code_manager/wiki before bumping one.
  lockCodeManagerVersion = "6.0.0";
  lockCodeManagerComponent = pkgs.buildHomeAssistantComponent {
    owner = "raman325";
    domain = "lock_code_manager";
    version = lockCodeManagerVersion;
    format = "unzip";
    sourceRoot = ".";
    src = pkgs.fetchurl {
      url = "https://github.com/raman325/lock_code_manager/releases/download/${lockCodeManagerVersion}/lock_code_manager.zip";
      hash = "sha256-uxv1jZhQmCYMVGoPsYfXzm04XPrCAnlo05Zi3O9KpqY=";
    };
  };
  hacsComponent = pkgs.buildHomeAssistantComponent rec {
    owner = "hacs";
    domain = "hacs";
    version = "2.0.5";
    format = "unzip";
    sourceRoot = ".";
    src = pkgs.fetchurl {
      url = "https://github.com/hacs/integration/releases/download/${version}/hacs.zip";
      hash = "sha256-l75rgkpPOOaDcozG3XI2f2uLrQpDQosbO5h6MIet9BM=";
    };
    # Its requirement (aiogithubapi) is pip-installed by Home Assistant inside
    # the container at startup, so there is nothing to check at build time.
    dontCheckManifest = true;
    # The NixOS module's link script (reused by home-assistant-config below)
    # links every directory containing a manifest.json into
    # custom_components/, so HACS's two webpack build manifests (unused at
    # runtime -- nothing in HACS reads them) got linked in as the bogus
    # integrations `frontend_es5`/`frontend_latest`, failing every startup
    # with "Error loading integration ... KeyError: 'domain'".
    postInstall = ''
      rm $out/custom_components/hacs/hacs_frontend/frontend_{es5,latest}/manifest.json
    '';
  };
  # nixpkgs' frigate integration lags upstream; HA 2026.9 needs 5.15.5+ (its
  # device registry fix).
  frigateComponent = pkgs.buildHomeAssistantComponent rec {
    owner = "blakeblackshear";
    domain = "frigate";
    version = "5.15.6";
    src = pkgs.fetchFromGitHub {
      inherit owner;
      repo = "frigate-hass-integration";
      tag = "v${version}";
      hash = "sha256-xh8+X4C6QCb2Y4fbo60xCX3QuXEktbopB2DbOTfzAhA=";
    };
    # Same as HACS: the container pip-installs the requirements.
    dontCheckManifest = true;
  };
  petlibroComponent = pkgs.buildHomeAssistantComponent {
    owner = "local";
    domain = "petlibro";
    version = "1.0.0";
    src = componentSources.petlibro;
  };
  restoreStateSaveComponent = pkgs.buildHomeAssistantComponent {
    owner = "local";
    domain = "restore_state_save";
    version = "1.0.0";
    src = componentSources.restore_state_save;
  };
in
{
  imports = extraModules;

  # MQTT broker (newyork) connection is UI-only config in Home Assistant, set
  # up once with Settings > Devices & Services > Add Integration > MQTT:
  #   broker:   newyork (homelab.hosts.newyork.net.ip)
  #   port:     1883
  #   username: frigate
  #   password: `cat /run/agenix/mqtt-password` on this host
  # The secret itself is already declared by ../frigate, which uses the same
  # credential.

  # The MCP Server integration (Assist API at /api/mcp for remote MCP clients)
  # is likewise config-entry-only: Add Integration > Model Context Protocol
  # Server. Its options flow controls the exposed LLM APIs and whether
  # administrator access is required.

  # Home Assistant runs from the official container image (see
  # `virtualisation.oci-containers.containers.homeassistant` below), because
  # nixpkgs' build can't install integration requirements at runtime -- and
  # re-enabling pip on it breaks every integration whose nixpkgs versions
  # don't match HA's exact pins (tried and reverted in 6a672bd). The image
  # ships its own Python, so any integration (or HACS download) can be set up
  # from the UI.
  #
  # This module is kept only as a *config generator*: it still renders
  # configuration.yaml into /etc/home-assistant and provides the script that
  # links it and the custom components into /var/lib/hass. Its own systemd unit is disabled below.
  #
  # Dashboards are all storage mode, edited in the UI -- none are declared
  # here.
  #
  # Dashboard cards are not declared here either (no customLovelaceModules): they are
  # installed from HACS into /config/www/community, which also registers them
  # as Lovelace resources. That needs resource_mode "storage" -- HA's default,
  # and what the module leaves alone when customLovelaceModules is empty. The
  # module's symlinked www/nixos-lovelace-modules couldn't work here anyway:
  # the stock image, unlike nixpkgs' patched build, won't serve files behind a
  # link out of www/. Currently installed from HACS: advanced-camera-card,
  # weather-forecast-card, windy-card, auto-entities. lock_code_manager
  # registers its own strategy module in storage mode.
  # extraComponents/extraPackages are gone: they only fed the nixpkgs build,
  # and the container installs each integration's requirements itself.
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    customComponents = [
      frigateComponent
      hacsComponent
      petlibroComponent
      lockCodeManagerComponent
      restoreStateSaveComponent
    ];

    config = lib.mkMerge (
      [
        {
          # Includes dependencies for a basic setup
          # https://www.home-assistant.io/integrations/default_config/
          default_config = { };

          # Resources are in storage mode (cards come from HACS, see above),
          # where HA ignores a YAML `resources` list and warns if one is
          # present; the module emits an empty one regardless.
          lovelace.resources = null;

          # Automations made in the UI. The Nix-declared ones (automations.nix,
          # yale-locks.nix) go under the plain `automation` key, which the UI
          # can't edit; HA merges both. The UI writes automations.yaml itself,
          # but the include fails config validation until the file exists, so
          # tmpfiles creates it below.
          "automation ui" = "!include automations.yaml";

          # UI-created scenes require their backing file on first startup too.
          scene = "!include scenes.yaml";

          # Requests are reverse-proxied by caddy on newyork before reaching
          # this host, so Home Assistant needs to trust it to honor the
          # X-Forwarded-* headers it sets. Without this, external access
          # through the proxy fails with "400: Bad Request" complaining that
          # Home Assistant isn't set up for reverse proxies.
          # https://www.home-assistant.io/integrations/http/#reverse-proxies
          http = {
            use_x_forwarded_for = true;
            trusted_proxies = trustedProxies;
          };
          homeassistant = homeSettings;
        }
      ]
      ++ fragments
    );
  };

  # Silence a known noisy discovery client without allowing its probes.
  networking.firewall.extraInputRules = ''
    ip saddr ${quietDeviceAddress} tcp dport 40000 drop
  '';

  # The module's own unit ran the nixpkgs build; the container replaces it.
  systemd.services.home-assistant.enable = lib.mkForce false;

  systemd.tmpfiles.rules = [
    "d /var/lib/hass 0750 hass hass -"
    # Only written when missing; see "automation ui" above.
    "f /var/lib/hass/automations.yaml - - - - []"
    "f /var/lib/hass/scenes.yaml - - - - []"
  ];

  # Runs the disabled unit's preStart -- the module's script that links
  # /etc/home-assistant/configuration.yaml and the custom
  # components into /var/lib/hass -- so the container sees
  # exactly what the native service used to. The links point into
  # /etc/home-assistant and /nix/store, both mounted into the container.
  systemd.services.home-assistant-config = {
    serviceConfig.Type = "oneshot";
    script = config.systemd.services.home-assistant.preStart;
  };

  # Same pattern as podman-frigate: `wants` re-runs the oneshot on every
  # (re)start, and restartTriggers stand in for the module's reloadTriggers,
  # which were attached to the now-disabled unit.
  systemd.services.podman-homeassistant = {
    after = [ "home-assistant-config.service" ];
    wants = [ "home-assistant-config.service" ];
    restartTriggers = [
      config.environment.etc."home-assistant/configuration.yaml".source
      config.systemd.services.home-assistant-config.script
    ];
  };

  virtualisation.oci-containers.containers.homeassistant = {
    image = homeAssistantImage;
    environment.TZ = config.services.home-assistant.config.homeassistant.time_zone;
    volumes = [
      "/var/lib/hass:/config"
      # The links in /config resolve through all three: /etc/home-assistant's
      # entries are themselves links into /etc/static, which is in the store.
      "/etc/home-assistant:/etc/home-assistant:ro"
      "/etc/static:/etc/static:ro"
      "/nix/store:/nix/store:ro"
      "/etc/localtime:/etc/localtime:ro"
      # Bluetooth, per upstream's container install docs.
      "/run/dbus:/run/dbus:ro"
    ];
    extraOptions = [
      # Upstream requires host networking for discovery (mDNS/SSDP/DHCP). It
      # also means 8123 is a real host socket: unlike frigate's
      # netavark-published ports, it stays behind the NixOS firewall, so
      # `openFirewall`, the living-room-tv drop above and
      # `http.trusted_proxies` keep working, and zwave-js-ui's server is still
      # reachable at 127.0.0.1:3000.
      "--network=host"
      # DHCP discovery sniffs DHCP requests on a raw socket, which podman's
      # default capability set doesn't allow ("Cannot watch for dhcp packets:
      # Operation not permitted"). Upstream's docs use --privileged for this;
      # these two capabilities are all it needs.
      "--cap-add=NET_RAW"
      "--cap-add=NET_ADMIN"
      # This host is also the NVR, so a leak in Home Assistant (or one of its
      # custom components) must not be able to push the kernel into
      # OOM-killing Frigate. Normal usage is ~0.5 GiB. The container runs in
      # its own libpod scope rather than the unit's cgroup, so a unit
      # MemoryMax would not apply; podman has no MemoryHigh-style throttle,
      # so only the hard cap carries over.
      "--memory=4g"
      # The unit's `podman stop` otherwise SIGKILLs HA after podman's default
      # 10s, before its shutdown finishes. That skips the final restore-state
      # write, so helpers set in the last 15 minutes come back reset. This
      # stays under the unit's 2-minute TimeoutStopSec.
      "--stop-timeout=110"
    ];
  };
}
