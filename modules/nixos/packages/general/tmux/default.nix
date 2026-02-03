{ inputs, lib, config, pkgs, ... }:

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
    newSession = true;
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
}
