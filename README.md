# homebrew-tap

> Homebrew formulas + cross-platform install scripts for [axhub](https://github.com/jocoding-ax-partners/ax-hub-cli) by Jocoding AX Partners.

## Install

### macOS (Homebrew — recommended)

```bash
brew install jocoding-ax-partners/tap/axhub
```

### macOS / Linux (universal install script)

```bash
curl -fsSL https://raw.githubusercontent.com/jocoding-ax-partners/homebrew-tap/main/install.sh | bash
```

Options via env var:
- `AXHUB_INSTALL_DIR=$HOME/bin` — custom install directory
- `AXHUB_VERSION=v0.1.0` — pin a specific version

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/jocoding-ax-partners/homebrew-tap/main/install.ps1 | iex
```

### Windows (Scoop)

```powershell
scoop bucket add jocoding-ax-partners https://github.com/jocoding-ax-partners/scoop-bucket
scoop install axhub
```

### Manual download

Grab the archive for your platform from
<https://github.com/jocoding-ax-partners/ax-hub-cli/releases/latest>.

## Uninstall

```bash
# Homebrew
brew uninstall axhub
brew untap jocoding-ax-partners/tap

# install.sh
rm -rf "$HOME/.axhub"

# Scoop
scoop uninstall axhub
```

## Verify signatures

Releases are signed with [cosign](https://github.com/sigstore/cosign) keyless OIDC from GitHub Actions:

```bash
cosign verify-blob \
  --certificate-identity-regexp "https://github.com/jocoding-ax-partners/ax-hub-cli" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate checksums.txt.pem \
  --signature checksums.txt.sig \
  checksums.txt
```

## Status

**v0.0.x** — placeholder formula. Real URLs/checksums are written automatically by
`goreleaser` on each upstream release tag.

## License

See [LICENSE](./LICENSE).
