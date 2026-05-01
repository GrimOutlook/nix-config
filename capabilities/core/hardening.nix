# This configuration is ripped directly from the wiki but options with large
# performance impacts were discarded.
# https://wiki.nixos.org/wiki/NixOS_Hardening
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.host.hardening;
in
{
  options.host.hardening.enable = mkEnableOption "Enable hardening configurations";
  config = mkIf cfg.enable {
    # Use the hardened kernel
    # WARN: This will need to be update manually.
    # The owner of the package (`anthraxx`) is a member of the Arch Linux
    # security team and is based in Germany.
    boot.kernelPackages =
      let
        linux_hardened_pkg =
          {
            fetchFromGitHub,
            buildLinux,
            lib,
            ...
          }@args:

          buildLinux (
            args
            // rec {
              version = "6.19.14-hardened1";

              modDirVersion = version;
              src = fetchFromGitHub {
                hash = "sha256-5DngEEC8YjkyGC30i3XNfzU86cs1iY31vDEltdW4Ai8=";
                owner = "anthraxx";
                repo = "linux-hardened";
                tag = "v${version}";
              };
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
          );
        linux_hardened = pkgs.callPackage linux_hardened_pkg { };
      in
      lib.recurseIntoAttrs (pkgs.linuxPackagesFor linux_hardened);

    # This option locks kernel modules after the system is initialized.
    # For example it prevents malicious USB devices from exploiting vulnerable
    # kernel modules.
    # WARN: All needed modules must be loaded at boot by adding them to
    # `boot.kernelModules`. One way of knowing what modules must be enabled is to
    # disable this option and then list all enabled modules with `lsmod`.
    security.lockKernelModules = true;

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
      "xt_connmark"
      "nf_conntrack_netlink"
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
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "ntfs"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"

      # Fixes CVE-2026-31431 -> CopyFail
      "algif_aead"
    ];

    # Prevents replacing the running kernel image.
    security.protectKernelImage = true;

    boot.kernelParams = [
      # Don't merge slabs
      "slab_nomerge"

      # Overwrite free'd pages
      "page_poison=1"

      # Enable page allocator randomization
      "page_alloc.shuffle=1"

      # Disable debugfs
      "debugfs=off"
    ];

    boot.kernel.sysctl = {
      # Hide kptrs even for processes with CAP_SYSLOG
      "kernel.kptr_restrict" = "2";

      # Disable bpf() JIT (to eliminate spray attacks)
      "net.core.bpf_jit_enable" = false;

      # Disable ftrace debugging
      "kernel.ftrace_enabled" = false;

      # Enable strict reverse path filtering (that is, do not attempt to route
      # packets that "obviously" do not belong to the iface's network; dropped
      # packets are logged as martians).
      "net.ipv4.conf.all.log_martians" = true;
      "net.ipv4.conf.all.rp_filter" = "1";
      "net.ipv4.conf.default.log_martians" = true;
      "net.ipv4.conf.default.rp_filter" = "1";

      # Ignore broadcast ICMP (mitigate SMURF)
      "net.ipv4.icmp_echo_ignore_broadcasts" = true;

      # Ignore incoming ICMP redirects (note: default is needed to ensure that the
      # setting is applied to interfaces added after the sysctls are set)
      "net.ipv4.conf.all.accept_redirects" = false;
      "net.ipv4.conf.all.secure_redirects" = false;
      "net.ipv4.conf.default.accept_redirects" = false;
      "net.ipv4.conf.default.secure_redirects" = false;
      "net.ipv6.conf.all.accept_redirects" = false;
      "net.ipv6.conf.default.accept_redirects" = false;

      # Ignore outgoing ICMP redirects (this is ipv4 only)
      "net.ipv4.conf.all.send_redirects" = false;
      "net.ipv4.conf.default.send_redirects" = false;
    };

    security.forcePageTableIsolation = true;

    # WARN: Apparently some programs won't work with the allocator. Maybe try
    # later and see if any issues are noticed.
    #
    # environment = {
    #   # Use security-focused memory allocator scudo. This is the default
    #   # allocator on Android since Android 11.
    #   memoryAllocator.provider = "scudo";
    #   variables.SCUDO_OPTIONS = "zero_contents=true";
    # };
    nix.settings.allowed-users = [ "@users" ];
  };
}
