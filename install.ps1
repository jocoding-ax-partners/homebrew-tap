# axhub installer for Windows (PowerShell).
#
# Usage (PowerShell):
#   irm https://raw.githubusercontent.com/jocoding-ax-partners/homebrew-tap/main/install.ps1 | iex
#
# Or pin a version:
#   $env:AXHUB_VERSION = "v0.1.0"; irm <url> | iex

$ErrorActionPreference = "Stop"

$Owner = "jocoding-ax-partners"
$Repo  = "ax-hub-cli"
$Bin   = "axhub.exe"

if ($env:AXHUB_INSTALL_DIR) {
    $InstallDir = $env:AXHUB_INSTALL_DIR
} else {
    $InstallDir = Join-Path $env:USERPROFILE ".axhub\bin"
}

function Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Fail($msg) { Write-Host "error: $msg" -ForegroundColor Red; exit 1 }

# 1. Arch detection
$arch = switch ($env:PROCESSOR_ARCHITECTURE) {
    "AMD64" { "amd64" }
    "ARM64" { "arm64" }
    default { Fail "unsupported architecture: $($env:PROCESSOR_ARCHITECTURE)" }
}

# 2. Resolve release tag
if ($env:AXHUB_VERSION) {
    $tag = $env:AXHUB_VERSION
    if (-not $tag.StartsWith("v")) { $tag = "v$tag" }
} else {
    $api = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
    $release = Invoke-RestMethod -Uri $api -Headers @{ "User-Agent" = "axhub-installer" }
    $tag = $release.tag_name
    if (-not $tag) { Fail "failed to resolve latest tag" }
}
$version = $tag -replace '^v', ''
Step "Installing axhub $tag for windows/$arch"

# 3. Download archive + checksums
$archive = "axhub_${version}_windows_${arch}.zip"
$base    = "https://github.com/$Owner/$Repo/releases/download/$tag"
$tmp     = New-Item -ItemType Directory -Path ([IO.Path]::Combine($env:TEMP, [IO.Path]::GetRandomFileName()))

try {
    Step "Downloading $archive"
    $zipPath = Join-Path $tmp $archive
    $sumPath = Join-Path $tmp "checksums.txt"
    Invoke-WebRequest -UseBasicParsing -Uri "$base/$archive"        -OutFile $zipPath
    Invoke-WebRequest -UseBasicParsing -Uri "$base/checksums.txt"   -OutFile $sumPath

    # 4. Verify sha256
    Step "Verifying checksum"
    $line = Get-Content $sumPath | Where-Object { $_ -match " $archive$" } | Select-Object -First 1
    if (-not $line) { Fail "checksums.txt missing entry for $archive" }
    $expected = ($line -split '\s+')[0].ToLower()
    $actual   = (Get-FileHash -Algorithm SHA256 -Path $zipPath).Hash.ToLower()
    if ($expected -ne $actual) { Fail "sha256 mismatch for $archive" }

    # 5. Extract + install
    Step "Installing to $InstallDir\$Bin"
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Expand-Archive -Path $zipPath -DestinationPath $tmp -Force
    $extracted = Join-Path $tmp $Bin
    if (-not (Test-Path $extracted)) { Fail "archive missing $Bin" }
    Move-Item -Force $extracted (Join-Path $InstallDir $Bin)

    Write-Host ""
    Write-Host "✓ axhub $tag installed at $InstallDir\$Bin" -ForegroundColor Green
    Write-Host ""
    Write-Host "Add to your PATH (persist for current user):"
    Write-Host "  [Environment]::SetEnvironmentVariable('Path', ([Environment]::GetEnvironmentVariable('Path','User') + ';$InstallDir'), 'User')"
    Write-Host ""
    Write-Host "Or one-shot for this session:"
    Write-Host "  `$env:Path = `"$InstallDir;`$env:Path`""
    Write-Host ""
    Write-Host "Verify: axhub --version"
    Write-Host "Docs:   https://github.com/$Owner/$Repo"
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
