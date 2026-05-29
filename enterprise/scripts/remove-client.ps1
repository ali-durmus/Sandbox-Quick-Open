$ErrorActionPreference = "Stop"

$InstallDir = "C:\Program Files\Sandbox Quick Open"
$NativeHostName = "com.sandboxquickopen.host"

Write-Host ""
Write-Host "Removing Sandbox Quick Open enterprise client..." -ForegroundColor Cyan
Write-Host ""

# Remove file/folder context menu from HKLM
$FileMenuRegPath = "Software\Classes\*\shell\OpenInWindowsSandbox"
[Microsoft.Win32.Registry]::LocalMachine.DeleteSubKeyTree($FileMenuRegPath, $false)

$DirectoryMenuRegPath = "Software\Classes\Directory\shell\OpenInWindowsSandbox"
[Microsoft.Win32.Registry]::LocalMachine.DeleteSubKeyTree($DirectoryMenuRegPath, $false)

# Remove Edge Native Messaging Host registry
$EdgeNativeHostRegPath = "Software\Microsoft\Edge\NativeMessagingHosts\$NativeHostName"
[Microsoft.Win32.Registry]::LocalMachine.DeleteSubKeyTree($EdgeNativeHostRegPath, $false)

# Remove installed files
if (Test-Path -LiteralPath $InstallDir) {
    Remove-Item -LiteralPath $InstallDir -Recurse -Force
}

Write-Host "Enterprise client removed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Removed:"
Write-Host "  File and folder context menu entries from HKLM"
Write-Host "  Edge Native Messaging Host registry entry from HKLM"
Write-Host "  $InstallDir"
Write-Host ""
Write-Host "Not removed automatically:"
Write-Host "  Edge extension force-install policy"
Write-Host "  Windows Sandbox feature"
Write-Host ""
Write-Host "If the Edge extension was deployed by GPO, remove or disable the related GPO policy:"
Write-Host "  HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist"
Write-Host ""