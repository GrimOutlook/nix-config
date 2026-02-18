# Hosts

| Hostname | Type |
| --- | --- |
| `horizon` | WSL |
| `washington` | Server VM |

## Installation

### Server VM

1. Create VM in Proxmox
2. Change Hardware->BIOS to `OVMF (UEFI)`
3. Boot the NixOS installer
4. Change the password for the `nixos` user to a known value.
5. Run the command `nix run github:nix-community/nixos-anywhere -- --flake </path/to/configuration>#<hostname> --target-host nixos@<vm.ip.address>`
