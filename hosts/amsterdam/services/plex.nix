{ homelab, host_info, ... }:
let
  port = host_info.services.plex.ports.default.number;

  # In-memory scratch space for the Plex transcoder's temporary segments so
  # transcode churn stays off the ZFS array. Kept small - Plex only needs a few
  # segments of look-ahead buffered at a time.
  #
  # Deliberately NOT under the plex data dir (/var/lib/plex): mounting a tmpfs
  # inside it makes systemd pre-create the whole mountpoint tree as root, which
  # loses the plex-owned data dir the module's ExecStartPre would otherwise
  # create - and Plex then can't write its database and fails to start.
  #
  # NOTE: Plex does not read its transcode directory from config on disk, so
  # after the first boot point it at this path in the web UI under
  # Settings -> Transcoder -> "Transcoder temporary directory".
  transcodeDir = "/var/cache/plex-transcode";

  # Media library roots on the ZFS storage array. Nix only creates the
  # directories (owned by plex so the scanner can read them); Plex libraries
  # themselves live in Plex's runtime database, so add each of these as a
  # library once via the web UI (+ -> Add Library -> point at the folder).
  libraryRoot = "/storage/Videos";
  libraryDirs = [
    "Movies"
    "TV"
    "Anime"
    "YouTube"
  ];
in
{
  services.plex = {
    enable = true;
    openFirewall = true;
    # Hardware (NVENC/NVDEC) transcoding on the RTX 3050 is provided by the
    # NVIDIA driver enabled in ../hardware/nvidia.nix; the plex process picks
    # up the userspace libraries from /run/opengl-driver automatically.
  };

  networking.firewall.extraInputRules = homelab.lib.firewallAllowLocal port;

  # Create the media library directory tree, owned by plex. Adding a trailing
  # entry here and rebuilding makes a new folder ready to add as a library.
  #
  # The first rule also asserts plex ownership of the data dir root itself,
  # which self-heals a data dir that a previous (nested) transcode mount left
  # owned by root. Runs before plex.service, and only touches this one
  # directory - not Plex's files underneath it.
  systemd.tmpfiles.rules = [
    "d /var/lib/plex 0755 plex plex -"
    "d ${libraryRoot} 0755 plex plex -"
  ]
  ++ map (dir: "d ${libraryRoot}/${dir} 0755 plex plex -") libraryDirs;

  # Small RAMDISK for transcode scratch files. mode=1777 (sticky, world
  # writable like /tmp) sidesteps having to track the plex uid while still
  # letting the plex service create and clean up its own session files.
  fileSystems.${transcodeDir} = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "size=4G"
      "mode=1777"
      "nosuid"
      "nodev"
    ];
  };

  # Refuse to start Plex unless the transcode RAMDISK is actually mounted.
  # Nothing in the plex unit references this path (it's a Plex runtime
  # setting, not a systemd directive), so without this systemd wouldn't order
  # or require the mount - and a failed mount would silently degrade to Plex
  # writing transcode segments onto the OS disk. RequiresMountsFor adds both
  # Requires= and After= on the generated tmpfs mount unit.
  systemd.services.plex.unitConfig.RequiresMountsFor = [ transcodeDir ];
}
