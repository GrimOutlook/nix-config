{
  cameraConfigs,
  streams,
  secretFiles,
  secretEnvironment,
  mqttHost,
  hostAddress,
  ports,
  firewallAllowLocal,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  videoPath = "/nvr/";
  mqttBroker = mqttHost;

  # Tracked on every camera.
  baseObjects = [
    "person"
    "cat"
    "dog"
  ];

  # Additionally tracked on the driveway camera only.
  vehicleObjects = [
    "car"
    "bicycle"
  ];

  trackedObjects = baseObjects ++ vehicleObjects;

  # YOLOv9 model for the Coral Edge TPU (not bundled with the Frigate image).
  # https://github.com/dbro/frigate-detector-edgetpu-yolo9
  yolov9ModelFile = "yolov9-s-relu6-best_320_int8_edgetpu.tflite";
  yolov9Model = pkgs.fetchurl {
    url = "https://github.com/dbro/frigate-detector-edgetpu-yolo9/releases/download/v1.0/${yolov9ModelFile}";
    sha256 = "14f5v6xfxb10s6fljj1pvrcamz1jxbkryvcs4l6msiwv8dvqx8s9";
  };
  yolov9LabelmapFile = "labels-coco17.txt";
  yolov9Labelmap = pkgs.fetchurl {
    # Pinned to a commit (rather than `main`) since the repo has no tagged release for this file.
    url = "https://raw.githubusercontent.com/dbro/frigate-detector-edgetpu-yolo9/d8ddfdaee7af76bf3847274604a5ecff0d8c1cc4/${yolov9LabelmapFile}";
    sha256 = "1mnqbp2gw4z539k7zj67jiyavl4465ca7p4gdxvj54bf71wqyxcl";
  };

  # Frigate 0.18 wants each mask as a named, toggleable entry. The camera
  # files keep plain coordinate lists; this converts them with the same IDs
  # and names Frigate's own config migrator would give them, so the masks
  # look the same in the UI as if Frigate had migrated them.
  toMaskDict =
    maskType: label: coords:
    lib.listToAttrs (
      lib.imap1 (i: c: {
        name = "${maskType}_${toString i}";
        value = {
          friendly_name =
            if label != "" then
              "Object Mask ${toString i} (${label})"
            else
              "${if maskType == "motion_mask" then "Motion Mask" else "Object Mask"} ${toString i}";
          enabled = true;
          coordinates = c;
        };
      }) coords
    );
  convertMasks =
    camera:
    lib.recursiveUpdate camera (
      lib.optionalAttrs (camera ? motion.mask) {
        motion.mask = toMaskDict "motion_mask" "" camera.motion.mask;
      }
      // lib.optionalAttrs (camera ? objects) {
        objects =
          lib.optionalAttrs (camera.objects ? mask) {
            mask = toMaskDict "object_mask" "" camera.objects.mask;
          }
          // lib.optionalAttrs (camera.objects ? filters) {
            filters = lib.mapAttrs (
              label: filter:
              lib.optionalAttrs (filter ? mask) { mask = toMaskDict "object_mask" label filter.mask; }
            ) camera.objects.filters;
          };
      }
    );

  cameras = lib.mapAttrs (_: convertMasks) cameraConfigs;

  frigateSettings = {
    # The config is regenerated on every start, so it is written in the
    # current format; this tells Frigate not to run its migrator over it.
    version = "0.18-0";

    mqtt = {
      enabled = true;
      host = mqttBroker;
      port = 1883;
      user = "frigate";
      # Substituted at activation time by frigate-config-setup.service.
      password = "$MQTT_PASSWORD";
      topic_prefix = "frigate";
    };

    # Frigate's own login is disabled -- newyork's Caddy already gates
    # the private video domain behind TinyAuth's forward-auth (see
    # tinyauth_auth in hosts/newyork/modules/services/caddy.nix), so a second
    # Frigate-native login would just be a redundant prompt after that.
    # `auth_secret` guards against header spoofing: Frigate's 8971 port is
    # podman-published, which netavark DNATs upstream of nixos' firewall
    # (same limitation as the metrics-proxy comment below), so it's directly
    # reachable on the LAN -- without this, anyone on the LAN could hit
    # Frigate directly and set Remote-User themselves to impersonate any
    # user. Caddy sends the matching X-Proxy-Secret header only on the
    # the private video domain vhost (see caddy.nix). Every
    # TinyAuth-authenticated user gets Frigate's `admin` role -- there's no
    # `groups` claim mapping configured to support finer-grained roles, and
    # everyone let past TinyAuth's forward-auth for this app is already a
    # trusted family member.
    auth.enabled = false;
    proxy = {
      auth_secret = "$FRIGATE_PROXY_AUTH_SECRET";
      # Matches one of the headers tinyauth_auth's copy_headers forwards
      # (see caddy.nix) -- Authentik's X-Authentik-Username predecessor is
      # gone now that Authentik is decommissioned.
      header_map.user = "remote-user";
      default_role = "admin";
    };

    networking.ipv6.enabled = false;

    ffmpeg = {
      hwaccel_args = "preset-vaapi";
    };

    record = {
      enabled = true;
      continuous.days = 180;
      motion.days = 365;
      detections.retain.days = 730;
      alerts.retain.days = 1095;
    };

    motion.enabled = true;
    detect.enabled = true;

    detectors.coral = {
      type = "edgetpu";
      device = "pci";
    };

    model = {
      model_type = "yolo-generic";
      width = 320;
      height = 320;
      path = "/config/model_cache/${yolov9ModelFile}";
      labelmap_path = "/config/${yolov9LabelmapFile}";
    };

    objects = {
      # Per-camera overrides (see cameras/driveway.nix) add car/bicycle back in.
      track = baseObjects;
      filters = lib.genAttrs trackedObjects (_: {
        min_score = 0.65;
      });
    };

    inherit cameras;

    # go2rtc streams aren't auto-derived from a camera's ffmpeg.inputs --
    # Frigate requires an explicit entry here for go2rtc/MSE-based live view
    # (e.g. the Advanced Camera Card's `live_provider: go2rtc`) to work.
    # Reuses each camera's detect-role (low-res) URL to keep dashboard live
    # view bandwidth down; recording still uses the high-res record-role
    # input, which is unaffected by this.
    go2rtc = {
      inherit streams;

      # Without this, go2rtc's default candidate list is `[stun:8555]`,
      # which STUNs out its own public IP and hands it to the browser as a
      # WebRTC candidate -- fine on LAN, but off-LAN that public IP:8555
      # isn't forwarded through newyork, so the browser's ICE connection
      # attempt lands as an unsolicited SYN on newyork's WAN interface.
      # newyork's `wan-drop` fail2ban jail treats that as scan noise and
      # bans the client's IP outright (bit us 2026-08-20: a legitimate
      # dashboard load off-LAN got the viewer banned within seconds of
      # opening a camera card). Pinning candidates to just the LAN IP
      # replaces that default, so go2rtc never advertises a public
      # candidate; off-LAN clients fail ICE locally (no packet ever reaches
      # newyork) and the Advanced Camera Card's `auto` live provider falls
      # back to MSE, which already tunnels through Caddy.
      webrtc.candidates = [ "${hostAddress}:8555" ];
    };

    tls.enabled = false;

    # date_style/time_style were removed in 0.18: the UI formats dates and
    # times from its language setting.
    ui = {
      time_format = "24hour";
      unit_system = "imperial";
    };
  };

  frigateCfgTemplate = (pkgs.formats.yaml { }).generate "frigate-config.yaml" frigateSettings;

  # `frigate-storage`: reports recording disk usage broken down by retention
  # category (alert / detection / motion / continuous) from the Frigate DB.
  # Run as root so it can `du` the media dir under ${videoPath}.
  frigate-storage = pkgs.writeShellApplication {
    name = "frigate-storage";
    runtimeInputs = [
      pkgs.python3
      pkgs.coreutils
    ];
    text = ''
      export FRIGATE_MEDIA="''${FRIGATE_MEDIA:-${videoPath}}"
      exec python3 ${./frigate-storage.py} "$@"
    '';
  };
in
{
  environment.systemPackages = [ frigate-storage ];

  age.secrets = builtins.mapAttrs (_: file: { inherit file; }) secretFiles;

  systemd.tmpfiles.rules = [
    "d ${videoPath} 0750 root root -"
    "d /var/lib/frigate-config 0755 root root -"
  ];

  # Frigate must not start before NTP has set the clock. Confirmed live
  # 2026-09-26: dunkirk rebooted with its RTC reading 2019, Frigate started,
  # and ~1 min later timesyncd stepped the clock forward ~6.8 years. The
  # watchdog saw the in-flight detection's 2019 start time as "stuck" and
  # restarted the detector, which never came back (Coral idle, 6165ms
  # "inference speed", 0 detection fps), and recording segments were
  # discarded until Frigate was restarted by hand. NixOS doesn't ship
  # systemd-time-wait-sync by default. The timeout keeps a dead NTP path
  # from blocking Frigate forever: `wants` still lets it start if the unit fails.
  systemd.additionalUpstreamSystemUnits = [ "systemd-time-wait-sync.service" ];
  systemd.services.systemd-time-wait-sync.serviceConfig.TimeoutStartSec = "5min";

  systemd.services."podman-frigate" = {
    after = [
      "agenix-install.service"
      "systemd-tmpfiles-setup.service"
      "frigate-config-setup.service"
      "time-sync.target"
    ];
    wants = [
      "frigate-config-setup.service"
      "systemd-time-wait-sync.service"
    ];
    # Restart the container whenever the generated config changes, so config
    # edits take effect on the next nixos-rebuild switch. Also restart on
    # frigate-proxy-auth-secret rotation -- confirmed live 2026-08-20 (a
    # different secret, same class of bug on newyork's tinyauth) that a
    # container only reads its env/config once at start, so a secret
    # re-rendering under it silently leaves the running process on the old
    # value otherwise. Restarting podman-frigate re-triggers
    # frigate-config-setup first via its `wants`/`after` below (oneshots
    # without RemainAfterExit go back to inactive after running, so Wants=
    # starts them fresh), which is what actually re-reads the secret.
    #
    # Also restart on changes to frigate-config-setup's own script --
    # confirmed live 2026-08-24: a fix to that script's envsubst quoting left
    # frigateCfgTemplate and the auth secret untouched, so this trigger list
    # missed it and podman-frigate kept running the old broken config after
    # `nixos-rebuild switch` until manually restarted.
    restartTriggers = [
      frigateCfgTemplate
      config.age.secrets.frigate-proxy-auth-secret.file
      config.systemd.services."frigate-config-setup".script
    ];
  };

  systemd.services."frigate-config-setup" = {
    after = [ "agenix-install.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: value:
          if value.quote or false then
            "export ${name}=\"\\\"$(cat ${config.age.secrets.${value.secret}.path})\\\"\""
          else
            "export ${name}=\"$(cat ${config.age.secrets.${value.secret}.path})\""
        ) secretEnvironment
      )}
      ${pkgs.gettext}/bin/envsubst < ${frigateCfgTemplate} > /var/lib/frigate-config/config.yaml
    '';
  };

  virtualisation.oci-containers.containers.frigate = {
    # Pinned rather than `:stable`: podman only pulls a missing image, so the
    # floating tag never actually upgraded anything -- it stayed on whatever
    # was first pulled. Read the release notes' breaking changes when bumping.
    image = "ghcr.io/blakeblackshear/frigate:0.18.0";
    privileged = true;
    environment = {
      # The default iHD (intel-media-driver) VAAPI backend is unstable on this
      # Coffee Lake iGPU under concurrent scale_vaapi+hwdownload decode across
      # 4 cameras -- ffmpeg was crashing on "Failed to sync surface" /
      # "hwdownload: Failed to download frame: -5" roughly once a minute per
      # camera. The legacy i965 driver (also installed in the image) doesn't
      # hit this bug on this hardware; confirmed via a live test with the
      # container recreated with this env var (zero crashes over 6 minutes,
      # vs. ~1/minute before).
      LIBVA_DRIVER_NAME = "i965";
    };
    devices = [
      "/dev/apex_0:/dev/apex_0"
      "/dev/dri/renderD128:/dev/dri/renderD128"
    ];
    ports = [
      "${builtins.toString ports.default.number}:8971"
      "8554:8554"
      "8555:8555"
    ];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "${videoPath}:/media/frigate"
      "/var/lib/frigate-config:/config:rw"
      "${yolov9Model}:/config/model_cache/${yolov9ModelFile}:ro"
      "${yolov9Labelmap}:/config/${yolov9LabelmapFile}:ro"
    ];
    extraOptions = [
      "--cap-add=CAP_PERFMON" # Allows Intel GPU statistics to be monitored
      "--stop-timeout=30" # allow enough time to shut down the various services
      "--shm-size=3G"
      "--mount=type=tmpfs,target=/tmp/cache,tmpfs-size=1000000000" # 1GB In-memory filesystem for recording segment storage
      "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
      # Static address for frigate-metrics-proxy below to target. Podman's
      # published-ports mapping (the `ports` list above) is DNAT'd by
      # netavark in its own nftables table, entirely upstream of nixos'
      # firewall -- `networking.firewall.extraInputRules` cannot restrict a
      # port published that way, confirmed against this host's live
      # ruleset (netavark's chains all run `policy accept`). Frigate's
      # unauthenticated port 5000 is full admin API access, not just
      # metrics, so it is deliberately *not* in the `ports` list; instead
      # frigate-metrics-proxy listens on a real host socket that nixos'
      # firewall does see, and reaches this fixed container address
      # directly instead of through a published port.
      "--ip=10.88.0.10"
    ];
  };

  # Proxies a real host-side listener (filtered by nixos' firewall, unlike a
  # podman-published port -- see the `--ip` note above) to Frigate's
  # unauthenticated internal port, so newyork's Prometheus can reach
  # /api/metrics without a login flow. Frigate has no scoped API-key
  # mechanism, only browser-style JWT sessions.
  systemd.services.frigate-metrics-proxy = {
    description = "LAN-restricted proxy to Frigate's unauthenticated metrics port";
    after = [ "podman-frigate.service" ];
    requires = [ "podman-frigate.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${builtins.toString ports.metrics.number},fork,reuseaddr TCP:10.88.0.10:5000";
      Restart = "always";
      RestartSec = 5;
      DynamicUser = true;
    };
  };

  # Loopback-only proxy to the same unauthenticated port, so Home Assistant on
  # this host can use http://localhost:5000 for its Frigate integration (it
  # can't send the X-Proxy-Secret header Caddy adds). Bound to 127.0.0.1 by
  # socat itself rather than published by podman, whose ports bypass the
  # firewall (see the `--ip` note above).
  systemd.services.frigate-local-api-proxy = {
    description = "Loopback-only proxy to Frigate's unauthenticated API port";
    after = [ "podman-frigate.service" ];
    requires = [ "podman-frigate.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:5000,bind=127.0.0.1,fork,reuseaddr TCP:10.88.0.10:5000";
      Restart = "always";
      RestartSec = 5;
      DynamicUser = true;
    };
  };

  networking.firewall.extraInputRules = ''
    ${firewallAllowLocal ports.metrics.number}
  '';
}
