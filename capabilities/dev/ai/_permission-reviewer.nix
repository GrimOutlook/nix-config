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
    # Bun embeds its store path in shims. This fixed-output dependency cache
    # must not retain store references; the outer derivation patches the shims.
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-iQoFCKUwGRs2l9XlX1gsSMTbsUWOsTO2UqI46zi6Rw0=";
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
