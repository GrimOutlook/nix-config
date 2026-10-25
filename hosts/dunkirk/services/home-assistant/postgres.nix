{ ... }:
let
  # The server has no network at all (`--network=none`) and listens only on
  # this socket, which the Home Assistant container mounts. The directory
  # above it is root-only, so on the host only root can reach the socket --
  # that is what makes `trust` auth (no password, no agenix secret) safe here.
  #
  # Not under /run/hass-postgres: that is the container unit's own
  # RuntimeDirectory (oci-containers keeps its ctr-id there), which systemd
  # deletes whenever the unit stops and recreates empty -- without the socket
  # directory, so podman refused to start the container again.
  socketParent = "/run/hass-postgres-socket";
  socketDir = "${socketParent}/socket";
  dataDir = "/var/lib/hass-postgres";
  # Where the socket appears inside the Home Assistant container.
  containerSocketDir = "/run/postgresql";
in
{
  systemd.tmpfiles.rules = [
    "d ${socketParent} 0700 root root -"
    # The image's entrypoint chowns both to its own postgres user, so these
    # must not name an owner or mode: tmpfiles applies them to directories
    # that already exist too, on every boot *and* whenever a deploy changes
    # any tmpfiles rule -- which chowned the data directory back to root
    # under the running server and took the recorder down.
    "d ${socketDir} - - - -"
    "d ${dataDir} - - - -"
  ];

  virtualisation.oci-containers.containers.hass-postgres = {
    # Only the major version is pinned: minor updates are drop-in, but a new
    # major needs a dump/restore (or pg_upgrade) of ${dataDir}.
    image = "docker.io/library/postgres:17";
    environment = {
      POSTGRES_USER = "homeassistant";
      POSTGRES_DB = "homeassistant";
      # See socketDir above. The entrypoint refuses to initialise without
      # either a password or this.
      POSTGRES_HOST_AUTH_METHOD = "trust";
    };
    volumes = [
      "${dataDir}:/var/lib/postgresql/data"
      "${socketDir}:/var/run/postgresql"
    ];
    cmd = [
      "-c"
      "listen_addresses="
    ];
    extraOptions = [
      "--network=none"
      "--shm-size=256m"
      # Same reasoning as Home Assistant's cap: keep Frigate safe from the
      # OOM killer.
      "--memory=1g"
      # Same as Home Assistant's: without it the unit's `podman stop`
      # SIGKILLs the server after 10s, forcing crash recovery on the next
      # start. Stays under the unit's 2-minute TimeoutStopSec.
      "--stop-timeout=110"
    ];
  };

  virtualisation.oci-containers.containers.homeassistant = {
    dependsOn = [ "hass-postgres" ];
    volumes = [ "${socketDir}:${containerSocketDir}" ];
  };

  # The image ships psycopg2. The recorder retries its connection for ~30s,
  # which covers Postgres still starting up after the container starts.
  services.home-assistant.config.recorder.db_url =
    "postgresql://homeassistant@/homeassistant?host=${containerSocketDir}";
}
