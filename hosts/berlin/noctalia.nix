# Ported from this host's old hyprpanel layout. That config varied the layout
# per monitor (media only on monitors 0 and 2); this applies one layout to
# every monitor, since Noctalia hides the media widget when nothing is playing.
# Per-monitor layouts are available via `bar.screenOverrides` if wanted.
{
  host.noctalia.settings = {
    bar.widgets = {
      left = [
        { id = "ControlCenter"; }
        { id = "Workspace"; }
        { id = "ActiveWindow"; }
      ];
      center = [ { id = "MediaMini"; } ];
      right = [
        { id = "Volume"; }
        { id = "Microphone"; }
        {
          id = "SystemMonitor";
          showNetworkStats = true;
        }
        { id = "Tray"; }
        { id = "Clock"; }
        { id = "NotificationHistory"; }
      ];
    };
  };
}
