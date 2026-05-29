param(
    [Parameter(Mandatory=$false)]
    [string]$BaseUrl = "https://intranet.example.local/sandboxquickopen"
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$ConfigPath = Join-Path $ProjectRoot "enterprise\enterprise-config.ps1"

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Enterprise config file not found: $ConfigPath"
}

. $ConfigPath
$PackageRoot = Join-Path $ProjectRoot "enterprise\deployment-package"
$ZipOutputDir = Join-Path $ProjectRoot "enterprise\build\output"
$ZipPath = Join-Path $ZipOutputDir "sandbox-quick-open-enterprise-deployment.zip"

$BuildPackageScript = Join-Path $ProjectRoot "enterprise\build\scripts\Build-DeploymentPackage.ps1"

Write-Host ""
Write-Host "Creating enterprise deployment ZIP..." -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -LiteralPath $BuildPackageScript)) {
    throw "Build package script not found: $BuildPackageScript"
}

# Rebuild deployment package first
& $BuildPackageScript -BaseUrl $BaseUrl

if (-not (Test-Path -LiteralPath $PackageRoot)) {
    throw "Deployment package folder not found: $PackageRoot"
}

New-Item -ItemType Directory -Path $ZipOutputDir -Force | Out-Null

if (Test-Path -LiteralPath $ZipPath) {
    Remove-Item -LiteralPath $ZipPath -Force
}

Compress-Archive -Path (Join-Path $PackageRoot "*") -DestinationPath $ZipPath -Force

Write-Host ""
Write-Host "Enterprise deployment ZIP created successfully." -ForegroundColor Green
Write-Host ""
Write-Host "ZIP file:"
Write-Host "  $ZipPath"
Write-Host ""
Write-Host "Base URL:"
Write-Host "  $BaseUrl"
Write-Host ""
Write-Host "GPO ExtensionInstallForcelist value:"
Write-Host "$EnterpriseExtensionId;$BaseUrl/updates.xml"
Write-Host ""