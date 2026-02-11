{config, inputs, lib, self, ...}:
{
  system = {
    autoUpgrade.enable = false;
    stateVersion = "25.05";
  };
}
