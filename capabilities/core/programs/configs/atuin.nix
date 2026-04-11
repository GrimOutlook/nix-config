{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-program.atuin;
in
{
  options.host.default-program.atuin.enable =
    lib.mkEnableOption "Enable default atuin configurations";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Replacement for a shell history which records additional commands
      # context with optional encrypted synchronization between machines
      # https://github.com/atuinsh/atuin
      atuin
    ];

    programs.bash.interactiveShellInit = lib.mkOrder 1900 ''
      eval "$(atuin init bash)"
    '';

    environment.etc."atuin/config.toml".text = ''
      auto_sync = false
      update_check = false

      filter_mode = "host"
      # Show session history first, and then global history before the session
      # was started
      filter_mode_shell_up_key_binding = "session-preload"

      [stats]
      common_subcommands = ["cargo", "git", "nix", "cd"]
    '';

    environment.variables.ATUIN_CONFIG_DIR = "/etc/atuin";
  };
}
