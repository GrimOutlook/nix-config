# This configuration is ripped directly from the wiki but options with large
# performance impacts were discarded.
# https://wiki.nixos.org/wiki/NixOS_Hardening
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.host.hardening;
  nc-inputs = inputs.nix-config.inputs;

  # aarch64's syscall table drops a batch of legacy calls in favor of their
  # *at (or otherwise renamed) equivalents -- chmod/chown/lchown/open/creat
  # don't exist there at all. auditctl aborts loading the *entire* ruleset if
  # any single rule names an unknown syscall, so these must be omitted rather
  # than just harmlessly never firing. Keep them on x86 for coverage of old
  # binaries that still call them directly.
  isx86 = pkgs.stdenv.hostPlatform.isx86;
  syscallFlags = syscalls: lib.concatMapStrings (s: " -S ${s}") syscalls;
in
{
  options.host.hardening = {
    enable = mkEnableOption "Enable hardening configurations";

    kernel.enable = mkEnableOption "Enable the hardened kernel (custom-built from source, no shared binary cache -- opt-in separately from the rest of hardening)";
  };
  config = mkIf cfg.enable (
    lib.mkMerge [
      (mkIf cfg.kernel.enable (
        let
          # Build a hardened kernel from a `linux-hardened` source checkout.
          #
          # Version info is read straight out of the source tree's Makefile
          # instead of being hardcoded, so it always matches whatever `src`
          # resolves to.
          mkHardenedKernel =
            src:
            let
              makefileLines = lib.splitString "\n" (builtins.readFile "${src}/Makefile");
              getMakefileVar =
                name:
                let
                  prefix = "${name} = ";
                in
                lib.removePrefix prefix (
                  lib.findFirst (lib.hasPrefix prefix) (throw "linux-hardened: couldn't find `${name}` in Makefile")
                    makefileLines
                );
              version = "${getMakefileVar "VERSION"}.${getMakefileVar "PATCHLEVEL"}.${getMakefileVar "SUBLEVEL"}${getMakefileVar "EXTRAVERSION"}";
            in
            pkgs.callPackage (
              {
                buildLinux,
                lib,
                ...
              }@args:

              buildLinux (
                args
                // {
                  inherit version src;
                  modDirVersion = version;
                  kernelPatches = [ ];

                  structuredExtraConfig = with lib.kernel; {
                    # Perform additional validation of commonly targeted structures.
                    DEBUG_NOTIFIERS = yes;
                    DEBUG_PLIST = yes;
                    DEBUG_SG = yes;
                    DEBUG_VIRTUAL = yes;
                    SCHED_STACK_END_CHECK = yes;

                    # tell EFI to wipe memory during reset
                    # https://lwn.net/Articles/730006/
                    RESET_ATTACK_MITIGATION = yes;

                    # restricts loading of line disciplines via TIOCSETD ioctl to CAP_SYS_MODULE
                    CONFIG_LDISC_AUTOLOAD = option no;

                    # Enable init_on_free by default
                    INIT_ON_FREE_DEFAULT_ON = yes;

                    # Initialize all stack variables on function entry
                    INIT_STACK_ALL_ZERO = yes;

                    # Wipe all caller-used registers on exit from a function
                    ZERO_CALL_USED_REGS = yes;

                    # Enable the SafeSetId LSM
                    SECURITY_SAFESETID = yes;

                    # Reboot devices immediately if kernel experiences an Oops.
                    PANIC_TIMEOUT = freeform "-1";

                    # Enable gcc plugin options
                    GCC_PLUGINS = yes;

                    #A port of the PaX stackleak plugin
                    GCC_PLUGIN_STACKLEAK = yes;

                    # Runtime undefined behaviour checks
                    # https://www.kernel.org/doc/html/latest/dev-tools/ubsan.html
                    # https://developers.redhat.com/blog/2014/10/16/gcc-undefined-behavior-sanitizer-ubsan
                    UBSAN = yes;
                    UBSAN_TRAP = yes;
                    UBSAN_BOUNDS = yes;
                    UBSAN_LOCAL_BOUNDS = option yes; # clang only
                    CFI_CLANG = option yes; # clang only Control Flow Integrity since 6.1

                    # Disable various dangerous settings
                    PROC_KCORE = no; # Exposes kernel text image layout
                    INET_DIAG = no; # Has been used for heap based attacks in the past

                    # INET_DIAG=n causes the following options to not exist anymore, but since they are defined in common-config.nix,
                    # make them optional
                    INET_DIAG_DESTROY = option no;
                    INET_RAW_DIAG = option no;
                    INET_TCP_DIAG = option no;
                    INET_UDP_DIAG = option no;
                    INET_MPTCP_DIAG = option no;

                    # CONFIG_DEVMEM=n causes these to not exist anymore.
                    STRICT_DEVMEM = option no;
                    IO_STRICT_DEVMEM = option no;

                    # stricter IOMMU TLB invalidation
                    IOMMU_DEFAULT_DMA_STRICT = option yes;
                    IOMMU_DEFAULT_DMA_LAZY = option no;

                    # not needed for less than a decade old glibc versions
                    LEGACY_VSYSCALL_NONE = yes;
                  };
                }
                // (args.argsOverride or { })
              )
            ) { };

          # Two flake inputs, two kernel lines (see `flake.nix`):
          #
          # - `linux-hardened` tracks upstream's rolling per-minor-version
          #   branch, so `nix flake update` alone picks up new hardened patch
          #   releases -- no manual version/hash bump needed.
          # - `linux-hardened-zfs` is pinned to the newest hardened release that
          #   nixpkgs' `zfs` still considers supported. ZFS hosts use this one
          #   instead: nixpkgs' `zfs`/`zfsUnstable` cap the newest kernel they
          #   support (`kernelMaxSupportedMajorMinor`), so building
          #   `linux-hardened`'s current line on a ZFS host would make the zfs
          #   package `meta.broken`.
          #
          # WARN: When upstream cuts a new kernel minor version, the branch/tag
          # named in the relevant input URL needs to be bumped by hand -- that
          # step can't be automated away. Forgetting to keep
          # `linux-hardened-zfs` within ZFS's supported range trips the
          # assertion below instead of failing silently.
          #
          # The owner of the package (`anthraxx`) is a member of the Arch Linux
          # security team and is based in Germany.
          linux_hardened = mkHardenedKernel nc-inputs.linux-hardened;
          linux_hardened_zfs = mkHardenedKernel nc-inputs.linux-hardened-zfs;
        in
        {
          assertions = [
            {
              assertion =
                !config.boot.zfs.enabled
                || !(pkgs.linuxPackagesFor linux_hardened_zfs)
                .${config.boot.zfs.package.kernelModuleAttribute}.meta.broken;
              message = ''
                host.hardening: `linux-hardened-zfs` (${linux_hardened_zfs.version}, pinned in
                flake.nix) is newer than what `boot.zfs.package` (${config.boot.zfs.package.version})
                supports. Repin `linux-hardened-zfs` to a hardened release on a kernel line
                that `zfs`/`zfsUnstable` still supports.
              '';
            }
          ];

          boot.kernelPackages = lib.recurseIntoAttrs (
            pkgs.linuxPackagesFor (if config.boot.zfs.enabled then linux_hardened_zfs else linux_hardened)
          );
        }
      ))
      {
        # This option locks kernel modules after the system is initialized.
        # For example it prevents malicious USB devices from exploiting vulnerable
        # kernel modules.
        # WARN: All needed modules must be loaded at boot by adding them to
        # `boot.kernelModules`. One way of knowing what modules must be enabled is to
        # disable this option and then list all enabled modules with `lsmod`.
        security.lockKernelModules = true;
        security.unprivilegedUsernsClone = lib.mkDefault true;

        # Whitelist common kernel modules
        # TODO: Annotate what each one of these is for.
        boot.kernelModules = [
          # USB
          "usb_storage"
          "uinput"
          "usbhid"
          "usbserial"
          # DVD
          "udf"
          "iso9660"
          # GPU
          "amdgpu"
          "i915"
          # Networking
          "nft_chain_nat"
          "xt_conntrack"
          "xt_CHECKSUM"
          "xt_MASQUERADE"
          "ipt_REJECT"
          "ip6t_REJECT"
          "nf_reject_ipv4"
          "nf_reject_ipv6"
          "xt_mark"
          "xt_comment"
          "xt_multiport"
          "xt_addrtype"
          # Cryptographic primitives and user API
          "ansi_cprng"
          "cbc"
          "xts"
          "gcm"
          "ccm"
          "ghash"
          "crypto_user"
        ];

        # Blacklist old/unused kernel modules that are more likely to be vulnerable
        # TODO: Annotate what each one of these is for.
        boot.blacklistedKernelModules = [
          # Obscure network protocols
          "ax25"
          "netrom"
          "rose"

          # Old or rare or insufficiently audited filesystems
          "adfs"
          "affs"
          "bfs"
          "befs"
          "cramfs"
          "efs"
          "erofs"
          "exofs"
          "freevxfs"
          "f2fs"
          "hfs"
          "hfsplus"
          "hpfs"
          "jffs2"
          "jfs"
          "minix"
          "nilfs2"
          "ntfs"
          "omfs"
          "qnx4"
          "qnx6"
          "sysv"
          "ufs"

          # Rarely-used network protocols with a history of kernel vulnerabilities
          "dccp"
          "sctp"

          # Fixes CVE-2026-31431 -> CopyFail
          "algif_aead"
        ];

        # Prevents replacing the running kernel image.
        security.protectKernelImage = true;

        boot.kernelParams = [
          # Don't merge slabs
          "slab_nomerge"

          # Overwrite free'd pages & scrub memory by default
          "page_poison=1"
          "init_on_alloc=1"
          "init_on_free=1"

          # Enable page allocator randomization and kernel stack offset randomization
          "page_alloc.shuffle=1"
          "randomize_kstack_offset=on"

          # Disable debugfs
          "debugfs=off"

          # Kernel audit and FIPS validation
          "fips=1"
          "audit=1"
          "audit_backlog_limit=8192"

          # Disable legacy vsyscalls
          "vsyscall=none"

          # Kernel lockdown LSM in integrity mode
          "lockdown=integrity"

          # Disable kernel hibernation to prevent image tampering
          "nohibernate"

          # Panic on oops to prevent exploit progression
          "oops=panic"

          # Distrust CPU and bootloader RNG entropy sources for crypto security
          "random.trust_cpu=off"
          "random.trust_bootloader=off"

          # Hardware IOMMU and DMA attack protection
          "intel_iommu=on"
          "amd_iommu=on"
          "amd_iommu=force_isolation"
          "iommu=force"
          "iommu.passthrough=0"
          "iommu.strict=1"
          "efi=disable_early_pci_dma"
        ];

        boot.kernel.sysctl = {
          # Enable full ASLR
          "kernel.randomize_va_space" = lib.mkDefault 2;

          # Hide kptrs even for processes with CAP_SYSLOG
          "kernel.kptr_restrict" = lib.mkForce 2;

          # Restrict dmesg to processes with CAP_SYSLOG
          "kernel.dmesg_restrict" = lib.mkDefault true;

          # Append PID to core dump filenames to prevent overwriting/symlink attacks
          "kernel.core_uses_pid" = lib.mkDefault 1;

          # Only allow tracing/attaching to direct child processes (ptrace_scope 1)
          "kernel.yama.ptrace_scope" = lib.mkDefault "1";

          # Disable bpf() JIT (to eliminate spray attacks) and harden JIT compiler
          "net.core.bpf_jit_enable" = lib.mkDefault false;
          "net.core.bpf_jit_harden" = lib.mkDefault 2;

          # Require CAP_SYS_ADMIN/CAP_BPF to load BPF programs
          "kernel.unprivileged_bpf_disabled" = lib.mkDefault true;

          # Restrict userfaultfd to root to eliminate heap use-after-free exploits
          "vm.unprivileged_userfaultfd" = lib.mkDefault 0;

          # Maximize ASLR entropy. The valid range is architecture- (and even
          # VA-bits-config-) dependent -- 32 is right for x86_64 but exceeds
          # aarch64's max, which fails with EINVAL and takes the whole
          # systemd-sysctl unit down with it. Leave aarch64 (e.g. dubai) on
          # the kernel's own per-arch default instead of guessing a value.
          "vm.mmap_rnd_bits" = lib.mkIf pkgs.stdenv.hostPlatform.isx86 (lib.mkDefault 32);
          "vm.mmap_rnd_compat_bits" = lib.mkIf pkgs.stdenv.hostPlatform.isx86 (lib.mkDefault 16);

          # Disable ftrace debugging
          "kernel.ftrace_enabled" = lib.mkDefault false;

          # Mitigate SYN flood DoS attacks (kernel default, set explicitly)
          "net.ipv4.tcp_syncookies" = lib.mkDefault true;

          # Disable TCP timestamps to prevent host uptime leaks
          "net.ipv4.tcp_timestamps" = lib.mkDefault 0;

          # Shield against RFC 1337 TIME-WAIT assassination attacks
          "net.ipv4.tcp_rfc1337" = lib.mkDefault 1;

          # Reduce time sockets stay in TIME_WAIT state to resist resource exhaustion
          "net.ipv4.tcp_fin_timeout" = lib.mkDefault 15;

          # Limit SYN backlog queue size
          "net.ipv4.tcp_max_syn_backlog" = lib.mkDefault 2048;

          # Disable packet forwarding (default 0; routers can override)
          "net.ipv4.ip_forward" = lib.mkDefault 0;
          "net.ipv6.conf.all.forwarding" = lib.mkDefault 0;
          "net.ipv6.conf.default.forwarding" = lib.mkDefault 0;

          # Disable source-routed packets
          "net.ipv4.conf.all.accept_source_route" = lib.mkDefault false;
          "net.ipv4.conf.default.accept_source_route" = lib.mkDefault false;
          "net.ipv6.conf.all.accept_source_route" = lib.mkDefault 0;
          "net.ipv6.conf.default.accept_source_route" = lib.mkDefault 0;

          # Ignore bogus ICMP error responses
          "net.ipv4.icmp_ignore_bogus_error_responses" = lib.mkDefault true;

          # Enable strict reverse path filtering
          "net.ipv4.conf.all.log_martians" = lib.mkDefault true;
          "net.ipv4.conf.all.rp_filter" = lib.mkDefault "1";
          "net.ipv4.conf.default.log_martians" = lib.mkDefault true;
          "net.ipv4.conf.default.rp_filter" = lib.mkDefault "1";

          # Ignore broadcast ICMP (mitigate SMURF)
          "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkDefault true;

          # Ignore incoming ICMP redirects
          "net.ipv4.conf.all.accept_redirects" = lib.mkDefault false;
          "net.ipv4.conf.all.secure_redirects" = lib.mkDefault false;
          "net.ipv4.conf.default.accept_redirects" = lib.mkDefault false;
          "net.ipv4.conf.default.secure_redirects" = lib.mkDefault false;
          "net.ipv6.conf.all.accept_redirects" = lib.mkDefault false;
          "net.ipv6.conf.default.accept_redirects" = lib.mkDefault false;

          # Ignore outgoing ICMP redirects
          "net.ipv4.conf.all.send_redirects" = lib.mkDefault false;
          "net.ipv4.conf.default.send_redirects" = lib.mkDefault false;

          # Local directory tree defense
          "fs.suid_dumpable" = lib.mkDefault 0;
          "fs.protected_symlinks" = lib.mkDefault 1;
          "fs.protected_hardlinks" = lib.mkDefault 1;
          "fs.protected_fifos" = lib.mkDefault 2;
          "fs.protected_regular" = lib.mkDefault 2;

          # Curb information leakage
          "kernel.stack_erasing" = lib.mkDefault 1;
          "dev.tty.ldisc_autoload" = lib.mkDefault 0;
          "kernel.perf_event_paranoid" = lib.mkDefault 3;

          # Lock physical console & limit PID allocation
          "kernel.sysrq" = lib.mkDefault 0;
          "kernel.pid_max" = lib.mkForce 65536;

          # Enable IPv6 privacy extensions
          "net.ipv6.conf.all.use_tempaddr" = lib.mkDefault 2;
          "net.ipv6.conf.default.use_tempaddr" = lib.mkDefault 2;

          # --- Performance Tuning (Safe settings from Linux kernel tuning guide) ---
          "vm.swappiness" = lib.mkDefault 10;
          "vm.dirty_background_ratio" = lib.mkDefault 10;
          "vm.dirty_ratio" = lib.mkDefault 40;
          "kernel.panic" = lib.mkDefault 10;
          "net.core.rmem_max" = lib.mkDefault 8388608;
          "net.core.wmem_max" = lib.mkDefault 8388608;
          "net.ipv4.tcp_rmem" = lib.mkDefault "4096 87380 8388608";
          "net.ipv4.tcp_wmem" = lib.mkDefault "4096 87380 8388608";
          "kernel.sched_min_granularity_ns" = lib.mkDefault 10000000;
          "kernel.sched_wakeup_granularity_ns" = lib.mkDefault 15000000;
          "fs.file-max" = lib.mkDefault 100000;
          "net.core.somaxconn" = lib.mkDefault 1024;
          "net.ipv4.tcp_window_scaling" = lib.mkDefault 1;
        };

        # Enable audit daemon and configure settings (alerts dispatched via Gotify per washington/newyork architecture)
        security.auditd = {
          enable = lib.mkDefault (!(config.wsl.enable or false));
          settings = {
            space_left = "10%";
            space_left_action = "ignore";
            admin_space_left = "5%";
            admin_space_left_action =
              "exec "
              + (pkgs.writeShellScript "auditd-gotify-alert" ''
                set -euo pipefail

                title="Auditd Storage Alert ($(hostname))"
                message="Auditd Warning: Low disk space threshold reached on host $(hostname)"
                priority="8"

                # Reads Gotify API key strictly from agenix secret file
                token_file="${config.age.secrets."gotify-default".path or "/run/agenix/gotify-default"}"
                if [ ! -r "$token_file" ]; then
                  echo "auditd-gotify-alert: Gotify key secret file not readable at $token_file, skipping alert" >&2
                  exit 0
                fi

                token="$(cat "$token_file")"
                if [ -z "$token" ]; then
                  echo "auditd-gotify-alert: Gotify key secret file is empty, skipping alert" >&2
                  exit 0
                fi

                target_url="https://notify.grimaldifamily.org/message"

                ${pkgs.curl}/bin/curl --silent --show-error --fail --output /dev/null \
                  --max-time 10 --retry 3 --retry-delay 2 --retry-connrefused \
                  --header "X-Gotify-Key: $token" \
                  --form-string "title=$title" \
                  --form-string "message=$message" \
                  --form-string "priority=$priority" \
                  "$target_url" || true
              '');
            num_logs = 10;
            max_log_file = 100;
            max_log_file_action = "rotate";
          };
        };

        # Configure comprehensive system auditing rules
        security.audit = {
          enable = lib.mkDefault (!(config.wsl.enable or false));
          rules = [
            # System auditing configuration modifications
            "-w /etc/audit/ -p wa -k auditconfig"
            "-w /var/log/audit/ -p wa -k auditlog"

            # Module loading and kernel operations
            "-a always,exit -F arch=b64 -S init_module -S finit_module -S delete_module -k modules"

            # Core execution monitoring
            "-a always,exit -F arch=b64 -S execve -k execution"

            # Discretionary access control modifications (chmod, chown)
            "-a always,exit -F arch=b64${syscallFlags ([ "fchmod" "fchmodat" ] ++ lib.optionals isx86 [ "chmod" ])} -k perm_mod"
            "-a always,exit -F arch=b64${syscallFlags ([ "fchown" "fchownat" ] ++ lib.optionals isx86 [ "chown" "lchown" ])} -k perm_mod"
            "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -k perm_mod"

            # Failed file access tracking (EACCES/EPERM)
            "-a always,exit -F arch=b64${syscallFlags ([ "openat" "truncate" "ftruncate" ] ++ lib.optionals isx86 [ "open" "creat" ])} -F exit=-EACCES -k access"
            "-a always,exit -F arch=b64${syscallFlags ([ "openat" "truncate" "ftruncate" ] ++ lib.optionals isx86 [ "open" "creat" ])} -F exit=-EPERM -k access"

            # Identity and group management tracking
            "-w /etc/group -p wa -k identity"
            "-w /etc/passwd -p wa -k identity"
            "-w /etc/shadow -p wa -k identity"

            # Login and session changes
            "-w /var/log/lastlog -p wa -k logins"
            "-w /var/run/utmp -p wa -k session"
            "-w /var/log/wtmp -p wa -k session"
            "-w /var/log/btmp -p wa -k session"

            # Network configuration modifications
            "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network"
            "-w /etc/issue -p wa -k network"
            "-w /etc/hosts -p wa -k network"

            # Mount/unmount actions
            "-a always,exit -F arch=b64 -S mount -S umount2 -k mount"
          ];
        };

        # Suppress memory dumps entirely to block secret leaks
        systemd.coredump.enable = false;

        security.forcePageTableIsolation = true;

        # Confine processes with a default-deny MAC policy where a profile
        # exists, and kill any process that should be confined but is running
        # unconfined (e.g. started before AppArmor was up).
        #
        # Disabled on WSL: nixos-wsl sets environment.etc."resolv.conf".enable
        # = false (WSL manages /etc/resolv.conf itself, outside the Nix
        # store) without ever setting a `source`. AppArmor's
        # abstractions/nameservice include unconditionally dereferences
        # config.environment.etc."resolv.conf".source whenever the attrset
        # entry exists at all (regardless of `enable`), which throws
        # "option ... has no value defined" during evaluation. AppArmor
        # confinement also has little value inside a WSL VM, so just skip it
        # there rather than trying to patch around the upstream conflict.
        security.apparmor = lib.mkIf (!(config.wsl.enable or false)) {
          enable = true;
          killUnconfinedConfinables = true;
          packages = [ pkgs.apparmor-profiles ];
        };

        # Declarative security precondition assertions
        assertions = [
          {
            assertion = config.users.users.root.hashedPassword == null;
            message = "Hardening Assertion: Root password login must be disabled (hashedPassword = null).";
          }
          {
            assertion = !config.security.sudo.enable && !config.security.sudo-rs.enable;
            message = "Hardening Assertion: Sudo must be disabled in favor of run0/polkit.";
          }
          {
            assertion = config.services.openssh.settings.PasswordAuthentication == false;
            message = "Hardening Assertion: SSH PasswordAuthentication must be disabled.";
          }
        ];

        # WARN: Apparently some programs won't work with the allocator. Maybe try
        # later and see if any issues are noticed.
        #
        # environment = {
        #   # Use security-focused memory allocator scudo. This is the default
        #   # allocator on Android since Android 11.
        #   memoryAllocator.provider = "scudo";
        # Global environment variables to enforce FIPS mode for compliant runtimes (OpenSSL, Go, etc.)
        environment.variables = lib.mkIf (!(config.wsl.enable or false)) {
          OPENSSL_FORCE_FIPS_HEADER = "1";
          OPENSSL_FIPS = "1";
          GOWITHFIPS = "1";
        };

        nix.settings.allowed-users = [ "@users" ];
      }
    ]
  );
}
