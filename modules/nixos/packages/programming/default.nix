
{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./git/default.nix
    ./dotnet.nix
  ];

  environment.systemPackages = with pkgs; [
    cmake # Cross-platform, open-source build system generator
    delta # Syntax-highlighting pager for git
    difftastic # Syntax-aware diff
    dos2unix # Convert text files with DOS or Mac line breaks to Unix line breaks and vice versa
    gh # GitHub CLI tool
    git-filter-repo # Quickly rewrite git repository history
    jujutsu # Git-compatible DVCS that is both simple and powerful
    just # Handy way to save and run project-specific commands
    mdbook # Create books from MarkDown
    pnpm # Fast, disk space efficient package manager for JavaScript
    ripsecrets # Command-line tool to prevent committing secret keys into your source code
    tokei # Count your code, quickly
  ];

  # NOTE: This module requires `fd`/`fdfind` to work fully but that isn't made explicit anywhere.
  # TODO: Make it explicit.
  environment.shellAliases = {
    lf="fd -t f -x dos2unix {} \;";
  };
}
