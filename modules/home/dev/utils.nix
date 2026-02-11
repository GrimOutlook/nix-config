{
  flake.modules.homeManager.dev =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        cmake # Cross-platform, open-source build system generator
        dos2unix # Convert text files with DOS or Mac line breaks to Unix line breaks and vice versa
        just # Handy way to save and run project-specific commands
        mdbook # Create books from MarkDown
        pnpm # Fast, disk space efficient package manager for JavaScript
        ripsecrets # Command-line tool to prevent committing secret keys into your source code
        tokei # Count your code, quickly
      ];

      # NOTE: This module requires `fd`/`fdfind` to work fully but that isn't made explicit anywhere.
      # TODO: Make it explicit.
      home.shellAliases = {
        lf="fd -t f -x dos2unix {} \;";
      };
    };
}
