# Backup hosts

Enable `host.backup.enable` for a dedicated Intel x86-64 backup host. This
capability replaces `nix-backup-host`: it bundles the server/network-diag
settings, SMART tools, administrative SSH keys, homelab home-manager settings,
hardware support, and the existing EFI/Btrfs disk layout (`/`, `/home`, `/nix`,
`/vault`). Set `host.backup.diskDevice` to the host's stable disk identifier.

The capability also provides the remote-initiated Washington pull service and
timer. Set the required `host.backup.washington.calendar` and optionally
`host.backup.washington.address` (default Washington's homelab FQDN). Repository,
host-key state and unit names are preserved: `/vault/backups/washington`,
`/var/lib/washington-backup`, and `washington-backup.service`. See Washington's
`BACKUP_PLAN.md` for key enrollment, host-key pinning and restore instructions.
Each host must explicitly set its backup schedule when enabling the capability.

The SSH private key is stored in `secrets/washington-ssh-key.age` and decrypted
by agenix to `/run/agenix/washington-backup-ssh-key`, root-owned mode 0400.
Oslo and Svalbard share this dedicated export-only identity; Washington
authorizes the matching `secrets/washington-ssh-key.pub` public key. Recipient
rules in `secrets/_secrets.nix` include both backup hosts' SSH host keys and the
administrative recovery identities. Rekey from that directory using
`ragenix --rules _secrets.nix -r` when recipients change.

The shared Restic password is stored in `secrets/washington-restic-password.age`
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
};
```
