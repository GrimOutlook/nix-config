# Ported from this host's old hyprpanel layout: menu/workspaces/window title on
# the left, nothing in the middle, system stats and status on the right.
# hyprpanel's separate cputemp/cpu/ram/netstat widgets are all one Noctalia
# SystemMonitor widget.
{
  host.noctalia.settings = {
    bar.widgets = {
      left = [
        { id = "ControlCenter"; }
        { id = "Workspace"; }
        { id = "ActiveWindow"; }
      ];
      center = [ ];
      right = [
        { id = "Volume"; }
        {
          id = "SystemMonitor";
          showNetworkStats = true;
        }
        { id = "Battery"; }
        { id = "Tray"; }
        { id = "Clock"; }
        { id = "NotificationHistory"; }
      ];
    };
  };
}
