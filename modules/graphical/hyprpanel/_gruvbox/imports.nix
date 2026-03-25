{ lib }:
lib.foldl' lib.recursiveUpdate {} [
  (import ./misc.nix)
  (import ./buttons/misc.nix)
  (import ./buttons/modules.nix)
  (import ./menu/battery.nix)
  (import ./menu/bluetooth.nix)
  (import ./menu/clock.nix)
  (import ./menu/dashboard.nix)
  (import ./menu/media.nix)
  (import ./menu/misc.nix)
  (import ./menu/network.nix)
  (import ./menu/notifications.nix)
  (import ./menu/power.nix)
  (import ./menu/systray.nix)
  (import ./menu/volume.nix)
]
