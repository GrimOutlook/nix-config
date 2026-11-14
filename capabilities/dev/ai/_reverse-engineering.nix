{ pkgs, lib }:
let
  ghidraSource = pkgs.fetchFromGitHub {
    owner = "LaurieWired";
    repo = "GhidraMCP";
    rev = "1e980252087b2479a21b9ca6d82d5829538651a7";
    hash = "sha256-kd7ITLhjT6KJL/sWUX8ySskhZh6nCzDG6AILgtJqJPM=";
  };
  ghidraExtension = pkgs.ghidra-extensions.buildGhidraExtension {
    pname = "GhidraMCP";
    version = "2.0";
    src = ghidraSource;
    sourceRoot = "source/extension";
  };
  ghidra = pkgs.ghidra.withExtensions (_: [ ghidraExtension ]);
  ghidraMcp = pkgs.python3Packages.buildPythonApplication {
    pname = "ghidra-mcp";
    version = "2.0.0";
    src = ghidraSource;
    pyproject = true;
    build-system = [ pkgs.python3Packages.hatchling ];
    dependencies = with pkgs.python3Packages; [
      mcp
      requests
    ];
    # The site's nixpkgs pins MCP 1.26; the stdio bridge uses its stable v1 API.
    pythonRelaxDeps = [ "mcp" ];
    pythonImportsCheck = [ "ghidra_mcp.cli" ];
    nativeCheckInputs = [ pkgs.python3Packages.pytestCheckHook ];
    disabledTestPaths = [ "tests/test_headless_integration.py" ];
    meta.mainProgram = "ghidra-mcp";
  };
  radare2Mcp = pkgs.stdenv.mkDerivation {
    pname = "radare2-mcp";
    version = "1.9.0-unstable-562c0cf";
    src = pkgs.fetchFromGitHub {
      owner = "radareorg";
      repo = "radare2-mcp";
      rev = "562c0cf23c42b65b3052f0b294d8778c20facbde";
      hash = "sha256-NMqp03awFNjNa2DdZCj6/TrnK5e/fjquyL/hC51JCyU=";
    };
    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.which
    ];
    buildInputs = [ pkgs.radare2 ];
    makeFlags = [ "PREFIX=$(out)" ];
    # Only install the stdio executable, not the optional r2 plugin or service.
    installPhase = ''
      runHook preInstall
      install -Dm755 src/r2mcp $out/bin/r2mcp
      runHook postInstall
    '';
  };
in
{
  packages = with pkgs; [
    ghidra
    radare2
    ghidraMcp
    radare2Mcp
    binutils
    file
    gdb
    strace
    ltrace
    patchelf
    elfutils
    xxd
  ];
  mcpServers = {
    ghidra = {
      command = lib.getExe ghidraMcp;
      args = [
        "--ghidra-server"
        "http://127.0.0.1:8080/"
      ];
      description = "Decompile and inspect binaries in the running Ghidra CodeBrowser (enable GhidraMCPPlugin).";
    };
    radare2 = {
      command = "${radare2Mcp}/bin/r2mcp";
      description = "Analyze binaries with radare2 over local stdio.";
    };
  };
  inherit ghidraExtension ghidraMcp radare2Mcp;
}
