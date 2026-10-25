# Applies a quiet BMC fan profile on this Supermicro board.
#
# The BMC (not the OS) owns the fans (same setup as amsterdam, another
# Supermicro X11 board -- see its README for that write-up). By default it
# runs in "Standard" mode, which held FAN1/FAN2 at ~2400-2500 RPM even with
# CPUs idling at 38-42 C. Switching to "Optimal" mode drops both fans to
# ~1100 RPM with CPU temps rising only a few degrees.
#
# Unlike amsterdam, this board does not hit the FAN1-idles-below-threshold
# oscillation bug: verified stable at 1100 RPM (well above the 700 RPM lower
# non-critical threshold) over several minutes, so no threshold adjustment is
# needed here.
#
# BMC fan settings are runtime-only and revert to factory defaults on a full
# A/C power loss or BMC cold reset, so re-applying them on each boot keeps the
# machine quiet without manual intervention.
{ pkgs, ... }:
{
  # ipmi_devintf provides /dev/ipmi0, which ipmitool talks to.
  boot.kernelModules = [
    "ipmi_si"
    "ipmi_devintf"
  ];

  # Make ipmitool available for manual re-runs / debugging too.
  environment.systemPackages = [ pkgs.ipmitool ];

  systemd.services.fan-control = {
    description = "Apply quiet BMC fan profile (Supermicro IPMI)";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # BMC settings can take a moment to accept after boot; retry the unit
      # rather than failing hard if the IPMI interface is briefly unready.
      Restart = "on-failure";
      RestartSec = 10;
    };

    path = [ pkgs.ipmitool ];
    script = ''
      set -euo pipefail

      # Wait for the local IPMI device to appear before talking to the BMC.
      for _ in $(seq 1 30); do
        [ -e /dev/ipmi0 ] && break
        sleep 1
      done

      # Fan mode -> Optimal (0x02): drops FAN1/FAN2 from ~2500 RPM (Standard)
      # to ~1100 RPM at idle, with CPU temps rising only ~3 C.
      ipmitool raw 0x30 0x45 0x01 0x02
    '';
  };
}
