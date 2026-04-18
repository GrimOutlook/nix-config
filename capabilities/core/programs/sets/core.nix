{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.default-programs.core;
in
{
  options.host.default-programs.core.enable = lib.mkEnableOption "Enable default core program set";

  config.environment = lib.mkIf cfg.enable {
    systemPackages = with pkgs; [

      # Low-level unprivileged sandboxing tool used by Flatpak and similar
      # projects
      # https://github.com/containers/bubblewrap
      bubblewrap

      # Human-friendly and fast alternative to cut and (sometimes) awk
      # https://github.com/theryangeary/choose
      choose

      # A tool for glamorous shell scripts
      # https://github.com/charmbracelet/gum
      gum

      # moreutils is a growing collection of the unix tools that nobody thought
      # to write long ago when unix was young
      # https://joeyh.name/code/moreutils/
      moreutils

      progress # Tool that shows the progress of coreutils programs
      pv # Tool for monitoring the progress of data through a pipeline
      rsync # Fast incremental file transfer utility
      sad # CLI tool to search and replace
      sd # Intuitive find & replace CLI (sed alternative)

      # A cli system trash manager, alternative to rm and trash-cli
      # https://github.com/oberblastmeister/trashy
      trashy

      uutils-coreutils-noprefix # Rust remade GNU coreutils. `-noprefix` makes it to where `cat` isn't `uutils-cat`.
      uutils-findutils # Rust remade GNU findutils
      uutils-diffutils # Rust remade GNU diffutils

      # Extended cp(1)
      xcp

      # Utils
      file
      git
      nfs-utils # Linux user-space NFS utilities
      tree
      wget
    ];

    shellAliases = {
      cdtmp = "cd $(mktemp -d)";
      cp = "xcp --verbose";
      mkdir = "mkdir --parents";
      mv = "mv --progress";

      # NOTE: Don't make an `rm` alias. Moving to a new system that doesn't
      # have trashy would result in unintended unrecoverable deletes.
      rt = "trash put";
      tp = "trash put";

      ##################
      # GNU core utils #
      ##################
      rm = "rm -iv";

      ########
      # Misc #
      ########
      t = "date +'%a %b %e %R:%S %Z %Y'";
    };
  };
}
