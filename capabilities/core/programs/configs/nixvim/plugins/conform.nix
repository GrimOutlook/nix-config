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

  # NOTE: gate the whole `host.home-manager.config` definition, not the value
  # inside it. When nixvim is disabled its home-manager module is never
  # imported, so a `mkIf false` nested *under* `programs.nixvim` would still be
  # a definition of an option that does not exist, and evaluation fails.
  config = lib.mkIf cfg.enable {
    host.home-manager.config.programs.nixvim = {
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
  };
}
