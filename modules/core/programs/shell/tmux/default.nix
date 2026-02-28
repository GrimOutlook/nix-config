{
  flake.modules.nixos.core =
    { lib, pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        # Use 24 hour clock.
        clock24 = true;
        # Maximum number of lines held in window history.
        historyLimit = 10000;
        # Automatically spawn a session if trying to attach and none are running.
        # WARN: Don't turn this on. This appears to already be default behavior and when this is
        # enabled it ends up spawning 2 sessions.
        newSession = false;
        # Set the $TERM variable. Use tmux-direct if italics or 24bit true color support is needed.
        terminal = "tmux-direct";
        # Rather than constraining window size to the maximum size of any client
        # connected to the *session*, constrain window size to the maximum size of any
        # client connected to *that window*. Much more reasonable.
        aggressiveResize = true;
        # Allows for faster key repetition
        escapeTime = 50;
        # List of plugins to install.
        plugins = with pkgs.tmuxPlugins; [
          gruvbox
          sensible
          tmux-which-key
          vim-tmux-navigator
          yank
        ];
        # Additional contents of /etc/tmux.conf, to be run after sourcing plugins.
        extraConfig =
          builtins.readFile ./tmux.conf + "\n" + ''set -g @vim_navigator_prefix_mapping_clear_screen ""'';
      };

      environment.shellAliases = {
        tm = "tmux";
        tms = "tmux new -s";
        tml = "tmux list-sessions";
        tma = "tmux attach -t";
        tmk = "tmux kill-session -t";
      };

      programs.bash.interactiveShellInit = ''
        # Verify that:
        # 1. TMUX command exists
        # 2. PS1 string is set and isn't ""
        # 3. We aren't in a screen session
        # 4. We aren't in a TMUX session already
        # 5. Additional check to make sure we aren't in a tmux session
        if command -v tmux &>/dev/null \
          && [ -n "$PS1" ] \
          && [[ ! "$TERM" =~ screen ]] \
          && [[ ! "$TERM" =~ tmux ]] \
          && [ -z "$TMUX" ]; then
          tmux new-session
        fi
      '';
    };
}
