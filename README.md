# homebrew-tap

> Homebrew formulas + cross-platform install scripts for [axhub](https://github.com/jocoding-ax-partners/ax-hub-cli) by Jocoding AX Partners.

## Install

### macOS (Homebrew — recommended)

```bash
brew install jocoding-ax-partners/tap/axhub
```

### macOS / Linux (universal install script)

```bash
curl -fsSL https://cli.jocodingax.ai/install.sh | bash
```

Options via env var:
- `AXHUB_INSTALL_DIR=$HOME/bin` — custom install directory
- `AXHUB_VERSION=vX.Y.Z` — pin a specific release tag when needed

### Windows (PowerShell)

```powershell
irm https://cli.jocodingax.ai/install.ps1 | iex
```

### Windows (Scoop)

```powershell
scoop bucket add jocoding-ax-partners https://github.com/jocoding-ax-partners/scoop-bucket
scoop install axhub
```

### Manual download

Grab the archive for your platform from
<https://cli.jocodingax.ai/version.txt> and the matching
`https://cli.jocodingax.ai/<version>/axhub_<version>_<os>_<arch>.<ext>` asset.

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

Full verification guide (version-pinning regex, Rekor transparency log, troubleshooting):
see [`docs/verify.md`](./docs/verify.md).

## Status

The checked-in formula currently targets **0.1.0**, and the install scripts
default to the latest release from `https://cli.jocodingax.ai/version.txt`
unless `AXHUB_VERSION` is set. Future tags continue to be updated by upstream
`goreleaser`.

## License

See [LICENSE](./LICENSE).
