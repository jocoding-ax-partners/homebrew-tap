# Placeholder — goreleaser overwrites this file on each upstream release tag.
# Manual reference: https://cli.jocodingax.ai
#
# HARD CONSTRAINT: On release, goreleaser runs `brew audit --strict` on this formula.
# Keep the structure valid even while URLs/sha256 are TODO placeholders.
class Axhub < Formula
  desc "CLI for the axhub developer platform"
  homepage "https://cli.jocodingax.ai"
  version "0.0.1"
  license :all_rights_reserved # Proprietary

  on_macos do
    on_arm do
      url "https://cli.jocodingax.ai/latest/darwin_arm64/axhub.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      url "https://cli.jocodingax.ai/latest/darwin_amd64/axhub.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_arm do
      url "https://cli.jocodingax.ai/latest/linux_arm64/axhub.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      url "https://cli.jocodingax.ai/latest/linux_amd64/axhub.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    bin.install "axhub"
  end

  test do
    system "#{bin}/axhub", "--version"
  end
end
