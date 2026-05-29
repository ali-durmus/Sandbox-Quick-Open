$ErrorActionPreference = "Stop"

$InstallDir = Join-Path $env:LOCALAPPDATA "Sandbox Quick Open"
$ShortcutName = "Open Clipboard URL in Windows Sandbox.lnk"
$RealDesktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $RealDesktop $ShortcutName

$StartMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Sandbox Quick Open"
$StartMenuShortcutPath = Join-Path $StartMenuDir $ShortcutName

$NativeHostName = "com.sandboxquickopen.host"

Write-Host ""
Write-Host "Uninstalling Sandbox Quick Open..." -ForegroundColor Cyan

# Remove file context menu
$FileMenuRegPath = "Software\Classes\*\shell\OpenInWindowsSandbox"
[Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($FileMenuRegPath, $false)

# Remove directory context menu
$DirectoryMenuRegPath = "Software\Classes\Directory\shell\OpenInWindowsSandbox"
[Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($DirectoryMenuRegPath, $false)

# Remove Chrome Native Messaging Host registry
$ChromeNativeHostRegPath = "Software\Google\Chrome\NativeMessagingHosts\$NativeHostName"
[Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($ChromeNativeHostRegPath, $false)

# Remove Edge Native Messaging Host registry
$EdgeNativeHostRegPath = "Software\Microsoft\Edge\NativeMessagingHosts\$NativeHostName"
[Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($EdgeNativeHostRegPath, $false)

# Remove desktop shortcut
if (Test-Path -LiteralPath $ShortcutPath) {
    Remove-Item -LiteralPath $ShortcutPath -Force
}
# Remove Start Menu shortcut/folder
if (Test-Path -LiteralPath $StartMenuShortcutPath) {
    Remove-Item -LiteralPath $StartMenuShortcutPath -Force
}

if (Test-Path -LiteralPath $StartMenuDir) {
    Remove-Item -LiteralPath $StartMenuDir -Recurse -Force
}
# Remove installed script/native-host folder
if (Test-Path -LiteralPath $InstallDir) {
    Remove-Item -LiteralPath $InstallDir -Recurse -Force
}

Write-Host ""
Write-Host "Sandbox Quick Open uninstalled successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Removed:"
Write-Host "  File and folder context menu entries"
Write-Host "  Chrome Native Messaging Host registry entry"
Write-Host "  Edge Native Messaging Host registry entry"
Write-Host "  Desktop shortcut"
Write-Host "  Start Menu shortcut"
Write-Host "  $InstallDir"
Write-Host ""
Write-Host "Not removed automatically:"
Write-Host "  Browser extension from Chrome/Edge"
Write-Host "  Windows Sandbox feature"
Write-Host ""
Write-Host "If you installed the browser extension manually, remove it from:"
Write-Host "  chrome://extensions"
Write-Host "  edge://extensions"
Write-Host ""