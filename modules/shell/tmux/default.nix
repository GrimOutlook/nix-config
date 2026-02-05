{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        tmux # Terminal multiplexer
      ];

      programs.tmux = {
        # Whenever to configure tmux system-wide.
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
        # Additional contents of /etc/tmux.conf, to be run before sourcing plugins.
        extraConfigBeforePlugins = ''
        '';
        # List of plugins to install.
        plugins = with pkgs.tmuxPlugins; [
          gruvbox
          sensible
          tmux-powerline
          tmux-which-key
          vim-tmux-navigator
          yank
        ];
        # Additional contents of /etc/tmux.conf, to be run after sourcing plugins.
        extraConfig = builtins.readFile ./tmux.conf;
      };

      environment.shellInit = builtins.readFile ./config.sh + builtins.readFile ./theme.sh + ''
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
