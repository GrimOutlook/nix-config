{
  inputs,
  self,
  nodes,
}:
let
  inherit (inputs) nixpkgs deploy-rs;
  inherit (nixpkgs) lib;

  # `deploy-rs.lib.<system>.activate.nixos` embeds the deploy-rs binary
  # built by the input's own (older) nixpkgs, whose fetchCrate still uses
  # the crates.io API URL that now 403s -- so that activation wrapper is
  # unbuildable anywhere. This is deploy-rs' documented workaround: keep
  # its activation *library*, but take the *binary* from our nixpkgs,
  # where it is cached.
  deployPkgsFor =
    system:
    import nixpkgs {
      inherit system;
      overlays = [
        deploy-rs.overlays.default
        (final: prev: {
          deploy-rs = {
            inherit (import nixpkgs { inherit system; }) deploy-rs;
            inherit (prev.deploy-rs) lib;
          };
        })
      ];
    };

  forAllSystems = lib.genAttrs [
    "x86_64-linux"
    "aarch64-linux"
  ];

  # `--rollback-succeeded false` has no flake attribute: deploy-rs reads it
  # only from the command-line opts (`cli.rs`), never from deploy data --
  # its `GenericSettings` schema carries just `autoRollback` and
  # `magicRollback`. So the default is set here, in a wrapper.
  #
  # Upstream defaults it to `true`, meaning if the seventh host fails to
  # *activate*, deploy-rs reverts the six that already succeeded. For a
  # fleet of unrelated machines that is backwards: a bad Frigate config on
  # pyongyang should not roll back a good newyork. Each host still rolls
  # *itself* back on failure via magicRollback/autoRollback.
  #
  # `--skip-checks` is on by default too. deploy-rs' pre-deploy
  # `nix flake check` evaluates `checks` below, i.e. `deployChecks` for
  # *every* node -- so deploying one host builds the whole fleet's
  # activation closures on the deployer first (aarch64 under qemu,
  # uncached source builds): a dunkirk-only deploy sat 45+ minutes in it
  # on 2026-09-26. The real build happens on the target anyway
  # (remoteBuild), and magicRollback still guards activation. Run
  # `nix flake check` by hand when you actually want the fleet checked.
  #
  # Both flags are injected only when absent: clap rejects a repeated
  # `--rollback-succeeded` or `--skip-checks` ("cannot be used multiple
  # times") rather than letting the last one win, so appending them
  # unconditionally would make the options impossible to override.
  mkDeploy =
    system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    pkgs.writeShellApplication {
      name = "deploy";
      # Called by full path, not via runtimeInputs: this wrapper is itself
      # named `deploy`, so putting the real one on PATH would recurse.
      text = ''
        rollback=1
        skip=1
        for arg in "$@"; do
          case "$arg" in
            # Everything past `--` is passed through to `nix build`.
            --) break ;;
            --rollback-succeeded | --rollback-succeeded=*) rollback= ;;
            # Also matches `s` in a bundle of short flags, e.g. `-ds`.
            --skip-checks | -s | -[!-]*s*) skip= ;;
          esac
        done
        defaults=()
        if [ -n "$rollback" ]; then defaults+=(--rollback-succeeded false); fi
        if [ -n "$skip" ]; then defaults+=(--skip-checks); fi
        exec ${pkgs.deploy-rs}/bin/deploy "''${defaults[@]}" "$@"
      '';
    };

  mkNode =
    name:
    {
      system,
      sshUser ? "deploy",
      hostname ? name,
      sshOpts ? [ ],
      remoteBuild ? true,
      confirmTimeout ? 30,
      sudo ? "sudo -n -u root /run/current-system/sw/bin/deploy-rs-sudo-bridge",
      interactiveSudo ? false,
    }:
    {
      inherit
        hostname
        sshUser
        sshOpts
        sudo
        interactiveSudo
        ;

      # Activate, then require the deployer to reconnect within
      # `confirmTimeout` seconds -- otherwise the host rolls itself back
      # to the previous generation.
      magicRollback = true;
      autoRollback = true;
      inherit confirmTimeout;

      profiles.system = {
        user = "root";
        path = (deployPkgsFor system).deploy-rs.lib.activate.nixos self.nixosConfigurations.${name};
        inherit remoteBuild;
      };
    };
in
{
  deploy.nodes = lib.mapAttrs mkNode nodes;

  # `nix run . -- .` deploys the fleet using the deploy key loaded in the
  # caller's SSH agent; `nix develop` puts the same wrapper on PATH as plain
  # `deploy`.
  #
  # Deliberately NOT named `deploy`: deploy-rs reads its node data by
  # evaluating `<flake>#deploy` (cli.rs), and Nix resolves that to
  # `packages.<system>.deploy` in preference to the top-level `deploy`
  # output -- so a package by that name hides the fleet from the tool.
  packages = forAllSystems (system: rec {
    deploy-fleet = mkDeploy system;
    default = deploy-fleet;
  });

  apps = forAllSystems (system: rec {
    deploy-fleet = {
      type = "app";
      program = lib.getExe (mkDeploy system);
      # `nix flake check` warns on apps without `meta`. `default` is
      # defined as this attribute, so one description covers both.
      meta.description = "Deploy the fleet, defaulting --rollback-succeeded to false";
    };
    default = deploy-fleet;
  });

  devShells = forAllSystems (system: {
    default = (import nixpkgs { inherit system; }).mkShellNoCC {
      packages = [ (mkDeploy system) ];
    };
  });

  # Fails the check if a node's profile does not evaluate or its
  # activation script is malformed. This is the schema validation the
  # commented-out `deployChecks` in nix-config was reaching for.
  checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
}
