# Verifying axhub release artifacts

All axhub binary releases are signed with [sigstore cosign](https://github.com/sigstore/cosign)
keyless OIDC from GitHub Actions (ADR-NEW-3). This guide shows how to verify
integrity and provenance before running a binary.

## Prerequisites

- `cosign` v2.x — https://docs.sigstore.dev/system_config/installation/
- Release version tag (e.g. `v0.1.0`) or the latest tag from `version.txt`
- Network access to `rekor.sigstore.dev`

## What is signed

`goreleaser` signs `checksums.txt` with cosign keyless OIDC. Because
`checksums.txt` contains the sha256 of every artifact, verifying that one
signature transitively verifies every archive (`axhub_*_darwin_arm64.tar.gz`,
`axhub_*_windows_amd64.zip`, ...).

Three files travel together per release:

| File | Purpose |
|---|---|
| `checksums.txt`      | one sha256 per artifact |
| `checksums.txt.sig`  | cosign signature of `checksums.txt` |
| `checksums.txt.pem`  | short-lived Fulcio certificate used to sign |

## Verify

All release assets live under `https://cli.jocodingax.ai/<version-without-v>/`.
Leave `VERSION` unset to verify the current release from `version.txt`, or
export `VERSION=v0.1.0` (or another tag) before running the commands below.

```bash
VERSION="${VERSION:-$(curl -fsSL https://cli.jocodingax.ai/version.txt)}"
CDN="https://cli.jocodingax.ai/${VERSION#v}"

curl -fsSL -O "$CDN/checksums.txt"
curl -fsSL -O "$CDN/checksums.txt.sig"
curl -fsSL -O "$CDN/checksums.txt.pem"

cosign verify-blob \
  --certificate-identity-regexp \
    "^https://github.com/jocoding-ax-partners/ax-hub-cli/\.github/workflows/release\.yml@refs/tags/${VERSION}$" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  --certificate checksums.txt.pem \
  --signature checksums.txt.sig \
  checksums.txt
```

Expected output: `Verified OK`.

Then verify the archive you actually downloaded:

```bash
ARCHIVE="axhub_${VERSION#v}_linux_arm64.tar.gz"
curl -fsSL -O "$CDN/$ARCHIVE"
grep "${ARCHIVE}$" checksums.txt | sha256sum -c -
```

## Transparency log

Every keyless signature is logged append-only to [Rekor](https://search.sigstore.dev/).
To find the entry for a release:

```bash
rekor-cli search --artifact checksums.txt
```

The returned UUID maps to a log entry whose `Subject` matches the
`--certificate-identity-regexp` used in the verify step. This proves the
signature existed at release time, even after the Fulcio cert expired.

## Troubleshooting

**`Error: no matching signatures`**
The certificate identity did not match. Most common cause: the `VERSION`
variable does not match the tag you actually downloaded. The regex is
anchored (`^...$`) — a trailing-slash or version-prefix mismatch fails.
Re-check `ls checksums.txt*` and your `$VERSION`.

**`Error: certificate expired`**
Fulcio certs live ~10 minutes — cosign proves validity *at signing time* via
Rekor, so you need network access to `rekor.sigstore.dev`. Air-gapped setups:
pre-download the Rekor bundle and pass `--rekor-url file://<bundle>`.

**`Error: fetching Rekor entry`**
Sigstore public infrastructure is down or blocked. Check
https://status.sigstore.dev. Retry after a short delay.

**Homebrew-installed axhub**
`brew install jocoding-ax-partners/tap/axhub` delegates integrity to
Homebrew's own sha256 pinning in the formula. Formula updates are produced
by the same `goreleaser` run, so verifying the release artifacts above is
equivalent to verifying the formula source.

## What this does NOT prove

- That the source code is bug-free or backdoor-free. Cosign attests *who
  built the binary* and *what the build output was*, not the code's safety.
- That you downloaded the intended release. Always confirm the version
  string in your URL matches the tag you expected.
