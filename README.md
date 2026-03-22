# nix-config

The structure of this configuration is based off of [this](https://github.com/GaetanLepage/nix-config)
repo.

## Nix Hosts

| Host | Summary |
| --- | --- |
| [belfast](https://github.com/GrimOutlook/nix-host-belfast) | Desktop |
| [london](https://github.com/GrimOutlook/nix-host-london) | Media |
| [newyork](https://github.com/GrimOutlook/nix-host-newyork) | Software Switch |
| [pyongyang](https://github.com/GrimOutlook/nix-host-pyongyang) | Security System |
| [taipei](https://github.com/GrimOutlook/nix-host-taipei) | Laptop WSL |
| [washington](https://github.com/GrimOutlook/nix-host-washington) | Web Service Host |

## Resources
- [NixOS Packages/Options](https://search.nixos.org/packages?channel=25.11)
- [HomeManager Options](https://home-manager-options.extranix.com/)
- [NixVim Options](https://nix-community.github.io/nixvim/25.11/index.html)
- [NixOS Virtual Machines](https://nix.dev/tutorials/nixos/nixos-configuration-on-vm)

## TODO

### WSL
- [ ] Add service to mount all windows drives.

### Non-WSL
- [ ] Look into switching to Refind.

### Graphical
- [ ] Add `eww` to hyprland.
- [ ] Change login screen to something that looks decent.
- [ ] Support wallpapers using `hyprpaper`.
- [ ] Add `hyprlock` for automatic sleep support.
