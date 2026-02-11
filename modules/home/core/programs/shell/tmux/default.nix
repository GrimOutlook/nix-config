{
  flake.modules.homeManager.core =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;

        # Rather than constraining window size to the maximum size of any client
        # connected to the *session*, constrain window size to the maximum size of any
        # client connected to *that window*. Much more reasonable.
        aggressiveResize = true;

        clock24 = true;

        # Allows for faster key repetition
        escapeTime = 50;

        keyMode = "vi";
        # Overrides the hjkl and HJKL bindings for pane navigation and resizing in VI mode
        customPaneNavigationAndResize = true;

        plugins = with pkgs.tmuxPlugins; [
          gruvbox
        ];

        extraConfig = builtins.readFile ./tmux.conf;
      };

      home.shellAliases = {
        tm = "tmux";
        tms = "tmux new -s";
        tml = "tmux list-sessions";
        tma = "tmux attach -t";
        tmk = "tmux kill-session -t";
      };
    };
}
