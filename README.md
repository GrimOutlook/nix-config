# nix-config

The structure of this configuration is based off of [this](https://github.com/GaetanLepage/nix-config)
repo.

## TODO

### WSL
- [ ] Add service to mount all windows drives.

### Non-WSL
- [ ] Look into switching to Refind.

### Graphical
- [x] Support wallpapers — handled by `noctalia`, not `hyprpaper`.
- [ ] Automatic sleep support. `noctalia` already provides the lock screen,
      so this is now just idle/suspend wiring rather than `hyprlock`.
- [ ] Add grub2 theme to make grub less boring.
    - Use [this one](https://github.com/vinceliuice/Elegant-grub2-themes)
