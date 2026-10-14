{
  ...
}:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Required for Xbox BLE controllers: ensures the encrypted LE link is
        # established before BlueZ attempts GATT attribute reads (HID/PNP_ID).
        FastConnectable = true;
        # Accept re-pairing attempts automatically. Xbox controllers re-pair
        # when they can't get a proper encrypted GATT session.
        JustWorksRepairing = "always";
        # Enables battery reporting on supported adapters.
        Experimental = true;
      };
    };
  };

  # xpadneo replaces the default hid-microsoft driver with one that correctly
  # handles Xbox controller BLE reconnection and input reporting.
  hardware.xpadneo.enable = true;

  # btusb autosuspend causes the adapter to drop the BLE connection when the
  # controller is idle. Disabling it keeps the link alive.
  boot.extraModprobeConfig = "options btusb enable_autosuspend=0";
}
