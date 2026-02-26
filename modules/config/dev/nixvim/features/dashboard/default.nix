{ config, ... }:
{
  flake.modules.homeManager.dev.programs.nixvim =
    { pkgs, ... }:
    {
      dependencies = {
        # Used to pixelate a PNG for display in Neovim
        chafa.enable = true;
      };

      plugins.snacks.settings.dashboard = {
        preset = {
          keys = [
            {
              icon = " ";
              key = "p";
              desc = "Projects";
              action = ":lua Snacks.dashboard.pick('projects')";
            }
            {
              icon = " ";
              key = "r";
              desc = "Recent Files";
              action = ":lua Snacks.picker.recent()";
            }
            {
              icon = " ";
              key = "f";
              desc = "Find File";
              action = ":lua Snacks.picker.files({ focus = 'input' })";
            }
            {
              icon = " ";
              key = "/";
              desc = "Find Text";
              action = ":lua Snacks.picker.grep({focus='input'})";
            }
            {
              icon = " ";
              key = "s";
              desc = "Find and Replace Text";
              action = ":lua require('grug-far').open() end";
            }
            # { icon = " "; key = "s"; desc = "Find and Replace Text"; action = function () require("utilities").openSearchAndReplace() end }
            {
              icon = "󱞋 ";
              key = "e";
              desc = "File Explorer (Oil)";
              action = "<CMD>Oil<CR>";
            }
            {
              icon = " ";
              key = "g";
              desc = "Git (Diff)";
              action = ":lua Snacks.dashboard.pick({ 'git_diff' })";
            }
            {
              icon = "󰀦 ";
              key = "n";
              desc = "Notifications";
              action = ":lua Snacks.dashboard.pick('notification')";
            }
            {
              icon = " ";
              key = "c";
              desc = "Config";
              action = ":lua Snacks.dashboard.pick('files'; {cwd = vim.fn.stdpath('config')})";
            }
            {
              icon = " ";
              key = "z";
              desc = "Restore Session";
              action = ":lua require('persistence').load({ last = true })";
            }
            {
              icon = " ";
              key = "q";
              desc = "Quit";
              action = ":qa";
            }
          ];
          header = ''
                        )  (    (      (    (      (     (        )
              *   )  ( /(  )\ ) )\ )   )\ ) )\ )   )\ )  )\ )  ( /(
            ` )  /(  )\())(()/((()/(  (()/((()/(  (()/( (()/(  )\()) (
             ( )(_))((_)\  /(_))/(_))  /(_))/(_))  /(_)) /(_))((_)\  )\
            (_(_())  _((_)(_)) (_))   (_)) (_))   (_))_|(_))   _((_)((_)
            |_   _| | || ||_ _|/ __|  |_ _|/ __|  | |_  |_ _| | \| || __|
              | |   | __ | | | \__ \   | | \__ \  | __|  | |  | .` || _|
              |_|   |_||_||___||___/  |___||___/  |_|   |___| |_|\_||___|
          '';
        };
        sections = [
          {
            section = "terminal";
            cmd = "${pkgs.coreutils-full}/bin/cat ${./thisisfine.txt}; sleep 0.1";
            padding = 1;
            height = 30;
          }
          {
            section = "header";
            pane = 2;
          }
          {
            pane = 2;
            section = "keys";
            gap = 1;
            padding = 1;
          }
        ];
      };
    };
}
