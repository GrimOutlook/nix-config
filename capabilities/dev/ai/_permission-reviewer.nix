# Shared build for the OpenCode plugin and Pi extension. Runtime imports are
# externalized and supplied by their respective hosts; node_modules is build-only.
{ inputs, pkgs }:
let
  src = inputs.nix-config.inputs.opencode-permission-reviewer;
  modules = pkgs.stdenv.mkDerivation {
    pname = "permission-reviewer-node-modules";
    version = "1.3.1";
    inherit src;
    nativeBuildInputs = [ pkgs.bun ];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild
      export HOME="$TMPDIR"
      bun install --frozen-lockfile --no-progress --ignore-scripts
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cp -R node_modules $out
      runHook postInstall
    '';
    # Keep the dependency cache identical to the frozen-lockfile install.
    # stdenv fixups rewrite shebangs and native binaries using the current
    # toolchain, making this fixed-output hash change after nixpkgs updates.
    # The outer derivation patches executable shims after copying the cache.
    dontFixup = true;
    __structuredAttrs = true;
    allowedReferences = [ ];
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-i9PG4EGWmHryDPaqz+8UO71ApVorVaM0i6VGn+VDatc=";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "permission-reviewer";
  version = "1.3.1-integration";
  inherit src;
  nativeBuildInputs = [
    pkgs.bun
    pkgs.nodejs
  ];
  dontConfigure = true;
  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"
    cp -R ${modules} node_modules
    chmod -R u+w node_modules
    for shim in node_modules/.bin/*; do
      target=$(readlink -f "$shim")
      if [ -f "$target" ]; then
        patchShebangs --build "$target"
      fi
    done
    bun run build
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R dist $out/dist
    cp package.json $out/package.json
    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    test -f $out/dist/index.js
    test -f $out/dist/tui/tui.tsx
    test -f $out/dist/pi.js
  '';
}
