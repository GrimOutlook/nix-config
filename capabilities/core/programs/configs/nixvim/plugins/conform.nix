{
  config,
  lib,
  ...
}:
let
  cfg = config.host.default-programs.nixvim.plugins.conform;
in
{
  options.host.default-programs.nixvim.plugins.conform.enable =
    lib.mkEnableOption "Enable nixvim conform plugin";

  config.host.home-manager.config.programs.nixvim = lib.mkIf cfg.enable {
    plugins.conform-nvim = {
      enable = true;

      # Whether to enable automatic installation of formatters listed in
      # settings.formatters_by_ft and settings.formatters.
      autoInstall = {
        enable = true;
        enableWarnings = true;
      };

      settings = {
        log_level = "debug";
        notify_on_error = true;
        notify_no_formatters = true;

        format_on_save = {
          lsp_format = "fallback";
          timeout_ms = 500;
        };

        format_after_save = {
          lsp_format = "fallback";
        };

        # NOTE: This is required to exist even if empty to prevent
        # `autoInstall.enable = true` from causing a nix build failure.
        formatters_by_ft = { };
      };
    };
    keymaps = [
      {
        mode = [ "n" ];
        key = "<leader>F";
        action = "<CMD>lua require('conform').format()<CR>";
        options.desc = "Format File";
      }
    ];
  };
}
