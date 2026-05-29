$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$ConfigPath = Join-Path $ProjectRoot "enterprise\enterprise-config.ps1"

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Enterprise config file not found: $ConfigPath"
}

. $ConfigPath

$RequiredFiles = @(
    "enterprise\deployment-package\DEPLOYMENT-NOTES.txt",

    "enterprise\deployment-package\client\deploy-client.ps1",
    "enterprise\deployment-package\client\remove-client.ps1",
    "enterprise\deployment-package\client\enable-windows-sandbox.ps1",
    "enterprise\deployment-package\client\Open-InSandbox.ps1",
    "enterprise\deployment-package\client\Setup-IisExtensionHosting.ps1",
    "enterprise\deployment-package\client\Open-Url-InSandbox.ps1",
    "enterprise\deployment-package\client\Open-ClipboardUrl-InSandbox.ps1",
    "enterprise\deployment-package\client\SandboxQuickOpenHost.ps1",
    "enterprise\deployment-package\client\SandboxQuickOpenHost.cmd",
    "enterprise\deployment-package\client\com.sandboxquickopen.host.json",

    "enterprise\deployment-package\extension\sandbox-quick-open-edge.crx",
    "enterprise\deployment-package\extension\updates.xml",

    "enterprise\deployment-package\gpo\edge-extension-force-install.reg",
    "enterprise\deployment-package\gpo\edge-native-host.reg",

    "enterprise\build\output\sandbox-quick-open-enterprise-deployment.zip"
)

Write-Host ""
Write-Host "Testing Sandbox Quick Open enterprise deployment package..." -ForegroundColor Cyan
Write-Host ""

$MissingFiles = @()

foreach ($RelativePath in $RequiredFiles) {
    $FullPath = Join-Path $ProjectRoot $RelativePath

    if (Test-Path -LiteralPath $FullPath) {
        Write-Host "[OK]      $RelativePath" -ForegroundColor Green
    }
    else {
        Write-Host "[MISSING] $RelativePath" -ForegroundColor Red
        $MissingFiles += $RelativePath
    }
}

Write-Host ""

if ($MissingFiles.Count -gt 0) {
    Write-Host "Deployment package test failed. Missing files:" -ForegroundColor Red
    foreach ($File in $MissingFiles) {
        Write-Host "  $File"
    }
    exit 1
}

Write-Host "Deployment package test passed." -ForegroundColor Green
Write-Host ""

$UpdatesXmlPath = Join-Path $ProjectRoot "enterprise\deployment-package\extension\updates.xml"
$ForceInstallRegPath = Join-Path $ProjectRoot "enterprise\deployment-package\gpo\edge-extension-force-install.reg"
$NativeHostManifestPath = Join-Path $ProjectRoot "enterprise\deployment-package\client\com.sandboxquickopen.host.json"

Write-Host "Quick content checks:" -ForegroundColor Cyan
Write-Host ""

if ((Get-Content $UpdatesXmlPath -Raw) -match "$EnterpriseExtensionId") {
    Write-Host "[OK] updates.xml contains enterprise extension ID." -ForegroundColor Green
}
else {
    Write-Host "[WARNING] updates.xml does not contain expected enterprise extension ID." -ForegroundColor Yellow
}

if ((Get-Content $ForceInstallRegPath -Raw) -match "ExtensionInstallForcelist") {
    Write-Host "[OK] Edge force-install registry file looks valid." -ForegroundColor Green
}
else {
    Write-Host "[WARNING] Edge force-install registry file may be invalid." -ForegroundColor Yellow
}

if ((Get-Content $NativeHostManifestPath -Raw) -match "chrome-extension://$EnterpriseExtensionId/") {
    Write-Host "[OK] Native host manifest allows enterprise extension ID." -ForegroundColor Green
}
else {
    Write-Host "[WARNING] Native host manifest does not allow expected enterprise extension ID." -ForegroundColor Yellow
}

Write-Host ""