# Backup hosts

Enable `host.backup.enable` for a dedicated Intel x86-64 backup host. This
capability replaces `nix-backup-host`: it bundles the server/network-diag
settings, SMART tools, homelab home-manager settings,
hardware support, and the existing EFI/Btrfs disk layout (`/`, `/home`, `/nix`,
`/vault`). Set `host.backup.diskDevice` to the host's stable disk identifier.

The capability also provides the remote-initiated Washington pull service and
timer. Set the required `host.backup.washington.calendar`,
`host.backup.washington.address`, `host.backup.washington.sshKeyFile`, and
`host.backup.washington.resticPasswordFile` from the private site. Repository,
host-key state and unit names are preserved: `/vault/backups/washington`,
`/var/lib/washington-backup`, and `washington-backup.service`. See Washington's
`BACKUP_PLAN.md` for key enrollment, host-key pinning and restore instructions.
Each host must explicitly set its backup schedule when enabling the capability.

Pulls use read-only rsync modules over the pinned SSH connection into a persistent,
root-only, unencrypted mirror at `/vault/mirrors/washington`. Unchanged files are
not downloaded again; `.rsync-partial` directories retain interrupted transfers.
The initial mirror still needs a full download and space for one complete copy
in addition to the encrypted repository. Restic runs only after all transfers
succeed, storing individual `storage/` and `snapshots/` paths with tag `incremental`.
Washington must be deployed with the matching rsync export before these clients.
Existing tar snapshots remain restorable until retention expires.

`washington-backup-maintenance.timer` runs weekly on Sunday at noon with up to an
hour of jitter. It applies 7 daily, 4 weekly, 12 monthly and 1 yearly retention,
prunes, and checks repository metadata. A shared lock serializes maintenance and
backup jobs. Retention groups by host, including both old tar and new snapshots.

Backup and maintenance completion hooks send Gotify messages identifying the
destination host and systemd exit result: priority **2** for a normal successful
exit and **8** for failure, timeout, or interruption. A successful backup message
means the rsync transfers and the Restic snapshot both completed. Updating the
unit reloads these hooks without restarting an in-flight mirror transfer.
The private site selects recipients and supplies the shared Gotify ciphertext,
decrypted root-only by the core Gotify capability. Notification delivery failures
are logged by the sender without changing the backup's result.

The SSH private key is supplied through `host.backup.washington.sshKeyFile` and decrypted
by agenix to `/run/agenix/washington-backup-ssh-key`, root-owned mode 0400.
The backup clients share a dedicated export-only identity; the source host
authorizes its matching public key. Authorized keys, ciphertext and recipient
rules are kept in the private site rather than this capability. For this fleet,
the backup credentials and rules are under `nix-homelab/secrets/backup/`.

The shared Restic password is supplied through `host.backup.washington.resticPasswordFile`
with the same recipients and decrypted to `/run/agenix/washington-restic-password`,
root-owned mode 0400. Both credentials are provided by agenix; no credential
initialization service is needed. `/var/lib/washington-backup` only holds the
pinned SSH `known_hosts` file. Keep an independent recovery copy of the encrypted
password and a recipient's private identity. Existing repositories created with
an older password need the new password added with `restic key add` using the
old password before switching credentials.

```nix
host.backup = {
  enable = true;
  diskDevice = "/dev/disk/by-id/your-backup-disk";
  washington.calendar = "02:00";
  washington.address = "backup-source.example.invalid";
  washington.sshKeyFile = ./secrets/backup-source-key.age;
  washington.resticPasswordFile = ./secrets/backup-repository-password.age;
};
```
