param(
    [Parameter(Mandatory=$false)]
    [string]$BaseUrl
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ConfigPath = Join-Path $ProjectRoot "enterprise\enterprise-config.ps1"

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Enterprise config file not found: $ConfigPath"
}

. $ConfigPath

$BuildEdgeExtensionScript = Join-Path $ProjectRoot "enterprise\build\scripts\Build-EdgeExtension.ps1"
$BuildDeploymentZipScript = Join-Path $ProjectRoot "enterprise\build\scripts\New-DeploymentZip.ps1"
$TestDeploymentPackageScript = Join-Path $ProjectRoot "enterprise\build\scripts\Test-DeploymentPackage.ps1"

Write-Host ""
Write-Host "Sandbox Quick Open - Enterprise Package Setup" -ForegroundColor Cyan
Write-Host ""

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    Write-Host "Enter the internal URL where the Edge extension files will be hosted."
    Write-Host "Example:"
    Write-Host "  https://intranet.company.local/sandboxquickopen"
    Write-Host ""

    $BaseUrl = Read-Host "Base URL"
}

$BaseUrl = $BaseUrl.Trim().TrimEnd("/")

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    throw "BaseUrl cannot be empty."
}

if ($BaseUrl -notmatch '^https?://') {
    throw "BaseUrl must start with http:// or https://"
}

$RequiredScripts = @(
    $BuildEdgeExtensionScript,
    $BuildDeploymentZipScript,
    $TestDeploymentPackageScript
)

foreach ($Script in $RequiredScripts) {
    if (-not (Test-Path -LiteralPath $Script)) {
        throw "Required script not found: $Script"
    }
}

Write-Host ""
Write-Host "Using Base URL:" -ForegroundColor Yellow
Write-Host "  $BaseUrl"
Write-Host ""

Write-Host "Step 1/3 - Building Edge extension CRX package..." -ForegroundColor Cyan
& $BuildEdgeExtensionScript

Write-Host ""
Write-Host "Step 2/3 - Creating enterprise deployment ZIP..." -ForegroundColor Cyan
& $BuildDeploymentZipScript -BaseUrl $BaseUrl

Write-Host ""
Write-Host "Step 3/3 - Testing deployment package..." -ForegroundColor Cyan
& $TestDeploymentPackageScript

$ExtensionId = $EnterpriseExtensionId
$ZipPath = Join-Path $ProjectRoot "enterprise\build\output\sandbox-quick-open-enterprise-deployment.zip"
$PackageRoot = Join-Path $ProjectRoot "enterprise\deployment-package"
$ExtensionFolder = Join-Path $PackageRoot "extension"
$ClientFolder = Join-Path $PackageRoot "client"
$GpoFolder = Join-Path $PackageRoot "gpo"

Write-Host ""
Write-Host "Enterprise setup completed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Output ZIP:"
Write-Host "  $ZipPath"
Write-Host ""
Write-Host "Deployment package:"
Write-Host "  $PackageRoot"
Write-Host ""
Write-Host "Files to host on your internal web server:"
Write-Host "  $ExtensionFolder\sandbox-quick-open-edge.crx"
Write-Host "  $ExtensionFolder\updates.xml"
Write-Host ""
Write-Host "Client deployment script:"
Write-Host "  $ClientFolder\deploy-client.ps1"
Write-Host ""
Write-Host "GPO files:"
Write-Host "  $GpoFolder\edge-extension-force-install.reg"
Write-Host "  $GpoFolder\edge-native-host.reg"
Write-Host ""
Write-Host "Edge ExtensionInstallForcelist value:"
Write-Host "  $ExtensionId;$BaseUrl/updates.xml"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Upload the extension folder files to:"
Write-Host "     $BaseUrl"
Write-Host ""
Write-Host "  2. Deploy client\deploy-client.ps1 to workstations as admin/startup script."
Write-Host ""
Write-Host "  3. Configure Edge ExtensionInstallForcelist via GPO:"
Write-Host "     $ExtensionId;$BaseUrl/updates.xml"
Write-Host ""
Write-Host "  4. Read DEPLOYMENT-NOTES.txt in the deployment package."
Write-Host ""