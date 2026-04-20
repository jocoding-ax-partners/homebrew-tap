#!/usr/bin/env bash
# axhub installer for macOS + Linux.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jocoding-ax-partners/homebrew-tap/main/install.sh | bash
#   AXHUB_INSTALL_DIR=$HOME/bin curl -fsSL ... | bash    # custom install path
#   AXHUB_VERSION=v0.1.0 curl -fsSL ... | bash           # pin version

set -euo pipefail

OWNER="jocoding-ax-partners"
REPO="ax-hub-cli"
BIN="axhub"
INSTALL_DIR="${AXHUB_INSTALL_DIR:-$HOME/.axhub/bin}"
CDN_BASE="${AXHUB_CDN_BASE:-https://cli.jocodingax.ai}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
err() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# 1. OS / arch detection
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$os" in
  darwin|linux) ;;
  *) err "unsupported OS: $os (use Homebrew on macOS or download the Windows zip manually)";;
esac
raw_arch="$(uname -m)"
case "$raw_arch" in
  x86_64|amd64) arch="amd64" ;;
  arm64|aarch64) arch="arm64" ;;
  *) err "unsupported architecture: $raw_arch";;
esac

# 2. Resolve release tag (default: latest from CDN, override with AXHUB_VERSION)
if [ -n "${AXHUB_VERSION:-}" ]; then
  tag="$AXHUB_VERSION"
  case "$tag" in v*) ;; *) tag="v$tag";; esac
else
  tag="$(curl -fsSL "$CDN_BASE/version.txt" | tr -d '\n\r ')"
  [ -n "$tag" ] || err "failed to resolve latest tag from $CDN_BASE/version.txt"
fi
version="${tag#v}"
log "Installing axhub $tag for $os/$arch"

# 3. Download archive + checksums
archive="axhub_${version}_${os}_${arch}.tar.gz"
base="$CDN_BASE/$version"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

log "Downloading $archive"
curl -fsSL -o "$tmp/$archive" "$base/$archive"
curl -fsSL -o "$tmp/checksums.txt" "$base/checksums.txt"

# 4. Verify sha256
log "Verifying checksum"
cd "$tmp"
if command -v sha256sum >/dev/null 2>&1; then
  grep " ${archive}$" checksums.txt | sha256sum -c -
else
  expected="$(grep " ${archive}$" checksums.txt | awk '{print $1}')"
  actual="$(shasum -a 256 "$archive" | awk '{print $1}')"
  [ "$expected" = "$actual" ] || err "sha256 mismatch for $archive"
fi
cd - >/dev/null

# 5. Extract + install
log "Installing to $INSTALL_DIR/$BIN"
mkdir -p "$INSTALL_DIR"
tar -xzf "$tmp/$archive" -C "$tmp"
[ -f "$tmp/$BIN" ] || err "archive missing $BIN binary"
mv "$tmp/$BIN" "$INSTALL_DIR/$BIN"
chmod +x "$INSTALL_DIR/$BIN"

# 6. Guidance
cat <<EOF

✓ axhub $tag installed at $INSTALL_DIR/$BIN

Add to your PATH (one-time, pick your shell):

  # bash / zsh
  echo 'export PATH="$INSTALL_DIR:\$PATH"' >> ~/.zshrc
  source ~/.zshrc

  # fish
  fish_add_path $INSTALL_DIR

Verify:
  axhub --version

Docs: https://github.com/${OWNER}/${REPO}
EOF
