$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$ExtensionDir = Join-Path $ProjectRoot "enterprise\edge-extension"
$OutputDir = Join-Path $ProjectRoot "enterprise\build\output"
$KeysDir = Join-Path $ProjectRoot "enterprise\build\keys"

$EdgePossiblePaths = @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

$EdgePath = $EdgePossiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $EdgePath) {
    throw "Microsoft Edge was not found. Cannot package extension."
}

if (-not (Test-Path $ExtensionDir)) {
    throw "Extension directory not found: $ExtensionDir"
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
New-Item -ItemType Directory -Path $KeysDir -Force | Out-Null

$ExtensionName = "sandbox-quick-open-edge"

$CrxOutputPath = Join-Path $OutputDir "$ExtensionName.crx"
$PemOutputPath = Join-Path $KeysDir "$ExtensionName.pem"

$ParentDir = Split-Path -Parent $ExtensionDir
$ExtensionFolderName = Split-Path -Leaf $ExtensionDir

$GeneratedCrx = Join-Path $ParentDir "$ExtensionFolderName.crx"
$GeneratedPem = Join-Path $ParentDir "$ExtensionFolderName.pem"

# Clean previous temporary generated files
if (Test-Path $GeneratedCrx) {
    Remove-Item $GeneratedCrx -Force
}

if (Test-Path $GeneratedPem) {
    Remove-Item $GeneratedPem -Force
}

Write-Host ""
Write-Host "Building Edge extension package..." -ForegroundColor Cyan
Write-Host ""

if (Test-Path $PemOutputPath) {
    Write-Host "Using existing private key:" -ForegroundColor Yellow
    Write-Host "  $PemOutputPath"
    Write-Host ""

    & $EdgePath --pack-extension="$ExtensionDir" --pack-extension-key="$PemOutputPath"
}
else {
    Write-Host "No existing private key found. Edge will generate a new key." -ForegroundColor Yellow
    Write-Host ""

    & $EdgePath --pack-extension="$ExtensionDir"
}

# Wait for Edge to finish writing the CRX package
$WaitSeconds = 0
while (-not (Test-Path $GeneratedCrx) -and $WaitSeconds -lt 10) {
    Start-Sleep -Seconds 1
    $WaitSeconds++
}

if (-not (Test-Path $GeneratedCrx)) {
    throw "Edge did not generate a CRX package at expected path: $GeneratedCrx"
}

if (-not (Test-Path $PemOutputPath)) {
    if (-not (Test-Path $GeneratedPem)) {
        throw "Edge did not generate a PEM key file at expected path: $GeneratedPem"
    }

    Move-Item $GeneratedPem $PemOutputPath -Force
}

Move-Item $GeneratedCrx $CrxOutputPath -Force

Write-Host ""
Write-Host "Edge extension package created successfully." -ForegroundColor Green
Write-Host ""
Write-Host "CRX package:"
Write-Host "  $CrxOutputPath"
Write-Host ""
Write-Host "Private key:"
Write-Host "  $PemOutputPath"
Write-Host ""
Write-Host "Important:"
Write-Host "  Keep the PEM file safe. The extension ID depends on this key."
Write-Host "  Do not delete or regenerate it unless you intentionally want a new extension ID."
Write-Host ""