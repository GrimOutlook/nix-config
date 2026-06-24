{
  config,
  lib,
  ...
}:
let
  cfg = config.host.dev.lang.rust;
in
{
  options.host.dev.lang.rust.enable = lib.mkEnableOption "Enable Rust language support";

  config = lib.mkIf cfg.enable {
    host.home-manager.config = {
      programs.nixvim = {
        plugins = {
          crates.enable = true;
          rustaceanvim = {
            enable = true;
            settings.server.default_settings.rust-analyzer = {
              check.command = "clippy";
              files.exclude = [ ".direnv/" ];
              files.excludeDirs = [ ".direnv" ];
              inlayHints.lifetimeElisionHints.enable = "always";
            };
          };
          conform-nvim.settings = {
            formatters_by_ft.rust = [ "rustfmt" ];
            formatters.rustfmt = {
              command = "rustfmt";
              # Prevent `rustfmt` from being installed by default. It should be installed by the project flake.
              package = null;
            };
          };
        };
        # Set up an autocommand to run when a Rust file is opened
        autoCmd = [
          {
            event = [ "FileType" ];
            pattern = [ "rust" ];
            callback = {
              __raw = ''
                function()
                  -- Only perform this check once per Neovim session
                  if _G._rustfmt_unstable_checked then return end
                  _G._rustfmt_unstable_checked = true

                  -- Ensure rustfmt is actually installed and in the PATH
                  if vim.fn.executable("rustfmt") == 1 then
                    -- Run rustfmt --help to check if it supports the unstable flag
                    local handle = io.popen("rustfmt --help 2>&1")
                    if handle then
                      local output = handle:read("*a")
                      handle:close()
                      
                      -- Check if the output contains the 'unstable-features' text
                      if output and string.find(output, "unstable%-features") then
                        -- Modify the existing built-in rustfmt formatter 
                        -- to safely prepend our unstable flag.
                        require("conform").formatters.rustfmt = {
                          prepend_args = { "--unstable-features" },
                        }
                      end
                    end
                  end
                end
              '';
            };
          }
        ];
      };
    };
  };
}
