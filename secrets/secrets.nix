let
  # Dev-system SSH host keys. These are the only machines that receive the
  # decrypted deployment key through the host agenix module.
  berlin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApGjkXLSbpQIvpIFbVeywyS8Y9rk0kQqPT5wjE/QEnX";
  paris = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISBaMUBkrHUa1Mglwy9pT9+PT4lk+cRL7c/cUoz2Gko";

  # Keep the editor's identity as a recipient so the secret can be rekeyed
  # without access to either dev system.
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbj7iF2skCHXK7Mil4xtdrGjFr69S1wA2YtFvjLgxEG";

  # Server host keys, for secrets that are consumed by daemons rather than by
  # a person at a dev system. Get one with `ssh-keyscan -t ed25519 <host>`;
  # agenix decrypts with /etc/ssh/ssh_host_ed25519_key, so it is the machine's
  # own host key that has to be on the list and never a user key.
  washington = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGk84To1yMMiTM6wtmZcryhFfE6Wp2zT4NtoQAz2HDxl";
  amsterdam = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDzmjRKUcc91nXGxE+BDqXLyn8BRmr31YXVDHO15GCj";
  dunkirk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6OsOZygckuVb+YEBOVyKHj+egE9fg8wFVBaTsZd2vk";
in
{
  "deploy-key.age" = {
    publicKeys = [
      berlin
      paris
      personal
    ];
    armor = true;
  };

  # Bitwarden/Vaultwarden managed-storage manifest for Firefox -- seeds the
  # self-hosted server URL so it never lands in this public repo in clear.
  # See `capabilities/graphical/firefox.nix`.
  "firefox-bitwarden-managed-storage.age" = {
    publicKeys = [
      berlin
      paris
      personal
    ];
    armor = true;
  };

  # Gotify application token for unattended infrastructure alerts, as opposed
  # to the per-service tokens newyork keeps in
  # `modules/services/notify/secrets/` -- those are encrypted to newyork alone
  # and posted over loopback, so nothing else in the fleet can use them. This
  # one is its own Gotify application so the hardware noise can be muted
  # without also muting sign-in notices.
  #
  # Consumed by root-run alert paths that have nowhere else to report, none of
  # which can send mail because these hosts have no MTA:
  #   - ZED, for checksum errors, degraded vdevs and scrub results
  #     (`capabilities/core/zfs.nix`)
  #   - mdadm --monitor, for the degraded ESP mirror on washington
  #   - auditd's admin_space_left_action (`capabilities/core/hardening.nix`)
  #
  # Recipients are the hosts that actually run one of those today. Adding a
  # host later means putting its key here and re-running `ragenix -r`, which
  # works from any dev system because `personal` is on the list.
  "gotify-default.age" = {
    publicKeys = [
      washington
      amsterdam
      dunkirk
      personal
    ];
    armor = true;
  };
}
