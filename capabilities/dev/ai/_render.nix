# Translates the shared allow/deny lists (see ./shared.nix) into each tool's
# own permission syntax. Pure function of the shared settings so the tool
# modules never restate the lists themselves.
#
# `directories` takes the tool's own extra directories (its scratch dir, say)
# and appends them to the shared set.
{ lib }:
shared: {
  claude = {
    commands = map (cmd: "Bash(${cmd}:*)") shared.allowedCommands;
    deniedCommands = map (cmd: "Bash(${cmd}:*)") shared.deniedCommands;
    directories = extra: shared.allowedDirectories ++ extra;
  };

  agy = {
    commands = map (cmd: "command(${cmd})") shared.allowedCommands;
    deniedCommands = map (cmd: "command(${cmd})") shared.deniedCommands;
    directories = extra: map (dir: "read_file(${dir})") (shared.allowedDirectories ++ extra);
  };

  opencode = {
    # OpenCode matches bash commands as globs against the whole command string,
    # so each shared prefix needs both the bare form (`git`) and the form with
    # arguments (`git *`). The denied prefixes are rendered the same way and the
    # `*` catch-all keeps everything unlisted going to the permission reviewer.
    bash =
      lib.listToAttrs (
        lib.concatMap (cmd: [
          (lib.nameValuePair cmd "allow")
          (lib.nameValuePair "${cmd} *" "allow")
        ]) shared.allowedCommands
        ++ lib.concatMap (cmd: [
          (lib.nameValuePair cmd "deny")
          (lib.nameValuePair "${cmd} *" "deny")
        ]) shared.deniedCommands
      )
      // {
        "*" = "ask";
      };

    # OpenCode matches external directories as globs, not prefixes.
    directories =
      extra:
      lib.listToAttrs (
        map (dir: lib.nameValuePair "${dir}/**" "allow") (shared.allowedDirectories ++ extra)
      );
  };
}
