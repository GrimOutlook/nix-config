## Installation

```bash
rm -rf /etc/nixos
# You will only need this If you are on a corporate VPN that requires it.
# export NIX_SSL_CERT_FILE='/my/certifiacate/file'
export NIX_CONFIG='experimental-features = nix-command flakes'
nix run nixpkgs#git -- clone https://github.com/GrimOutlook/devnix /etc/nixos
```
