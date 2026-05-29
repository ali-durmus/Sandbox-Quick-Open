$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Checking Windows Sandbox feature..." -ForegroundColor Cyan
Write-Host ""

$FeatureName = "Containers-DisposableClientVM"

$feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName

if ($feature.State -eq "Enabled") {
    Write-Host "Windows Sandbox is already enabled." -ForegroundColor Green
    exit 0
}

Write-Host "Windows Sandbox is not enabled."
Write-Host "Enabling feature: $FeatureName"
Write-Host ""

Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart

Write-Host ""
Write-Host "Windows Sandbox feature has been enabled." -ForegroundColor Green
Write-Host "A restart may be required before Windows Sandbox can be used."
Write-Host ""