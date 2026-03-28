{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      programs.git.settings.core.hooksPath = "~/.git-hooks";
      home.file.".git-hooks/pre-commit" = {
        executable = true;
        text = ''
          #!/bin/sh
          for hook in ~/git-hooks/pre-commit.d/*; do
            if [ -x "$hook" ]; then
              "$hook" "$@" || exit 1
            fi
          done
        '';
      };
    };
}
