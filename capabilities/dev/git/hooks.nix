{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    let
      hooks_path = ".config/git/hooks";
    in
    {
      programs.git.settings.core.hooksPath = "~/${hooks_path}";
      home.file."${hooks_path}/pre-commit" = {
        executable = true;
        text = ''
          #!/bin/sh
          for hook in ~/${hooks_path}/pre-commit.d/*; do
            if [ -x "$hook" ]; then
              "$hook" "$@" || exit 1
            fi
          done
        '';
      };
    };
}
