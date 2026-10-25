let
  default_layout = {
    left = [
      "dashboard"
      "workspaces"
      "windowtitle"
    ];
    middle = [
    ];
    right = [
      "volume"
      "microphone"
      "cputemp"
      "cpu"
      "ram"
      "netstat"
      "systray"
      "clock"
      "notifications"
    ];
  };
in
{
  host.hyprpanel.extraSettings = {
    bar.layouts = {
      "0" = default_layout // {
        middle = [ "media" ];
      };
      "1" = default_layout;
      "2" = default_layout // {
        middle = [ "media" ];
      };
    };
  };
}
