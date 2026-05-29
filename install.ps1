$ErrorActionPreference = "Stop"

$PowerShellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$MenuName = "Open in Windows Sandbox"
$ShortcutName = "Open Clipboard URL in Windows Sandbox.lnk"
$Hotkey = "CTRL+ALT+S"

$NativeHostName = "com.sandboxquickopen.host"
$ChromiumExtensionId = "eokaogaleloiehicgbojelipgbjlhdod"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path $ProjectRoot "src"
$NativeHostSourceDir = Join-Path $ProjectRoot "native-host"
$InstallDir = Join-Path $env:LOCALAPPDATA "Sandbox Quick Open"

$Scripts = @(
    "Open-InSandbox.ps1",
    "Open-Url-InSandbox.ps1",
    "Open-ClipboardUrl-InSandbox.ps1"
)

$NativeHostFiles = @(
    "SandboxQuickOpenHost.ps1",
    "SandboxQuickOpenHost.cmd"
)

Write-Host ""
Write-Host "Installing Sandbox Quick Open..." -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $PowerShellPath)) {
    throw "Windows PowerShell was not found at: $PowerShellPath"
}

if (-not (Test-Path -LiteralPath $SourceDir)) {
    throw "Source folder not found: $SourceDir"
}

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

# Copy main scripts
foreach ($Script in $Scripts) {
    $SourceScript = Join-Path $SourceDir $Script
    $TargetScript = Join-Path $InstallDir $Script

    if (-not (Test-Path -LiteralPath $SourceScript)) {
        throw "Required script not found: $SourceScript"
    }

    Copy-Item -LiteralPath $SourceScript -Destination $TargetScript -Force
}

# Copy native host files if available
if (Test-Path -LiteralPath $NativeHostSourceDir) {
    foreach ($NativeFile in $NativeHostFiles) {
        $SourceNativeFile = Join-Path $NativeHostSourceDir $NativeFile
        $TargetNativeFile = Join-Path $InstallDir $NativeFile

        if (Test-Path -LiteralPath $SourceNativeFile) {
            Copy-Item -LiteralPath $SourceNativeFile -Destination $TargetNativeFile -Force
        }
    }
}

$OpenInSandboxScript = Join-Path $InstallDir "Open-InSandbox.ps1"
$OpenClipboardUrlScript = Join-Path $InstallDir "Open-ClipboardUrl-InSandbox.ps1"
$NativeHostCmd = Join-Path $InstallDir "SandboxQuickOpenHost.cmd"
$NativeHostManifestPath = Join-Path $InstallDir "$NativeHostName.json"

$CommandValue = '"' + $PowerShellPath + '" -ExecutionPolicy Bypass -File "' + $OpenInSandboxScript + '" "%1"'

# File context menu
$FileMenuRegPath = "Software\Classes\*\shell\OpenInWindowsSandbox"
$FileCommandRegPath = "Software\Classes\*\shell\OpenInWindowsSandbox\command"

$RegKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($FileMenuRegPath)
$RegKey.SetValue("", $MenuName, [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.SetValue("Icon", "WindowsSandbox.exe", [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.Close()

$RegKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($FileCommandRegPath)
$RegKey.SetValue("", $CommandValue, [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.Close()

# Directory context menu
$DirectoryMenuRegPath = "Software\Classes\Directory\shell\OpenInWindowsSandbox"
$DirectoryCommandRegPath = "Software\Classes\Directory\shell\OpenInWindowsSandbox\command"

$RegKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($DirectoryMenuRegPath)
$RegKey.SetValue("", $MenuName, [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.SetValue("Icon", "WindowsSandbox.exe", [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.Close()

$RegKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($DirectoryCommandRegPath)
$RegKey.SetValue("", $CommandValue, [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.Close()

# Desktop shortcut for clipboard URL
$RealDesktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $RealDesktop $ShortcutName

$ShortcutArguments = "-ExecutionPolicy Bypass -File `"$OpenClipboardUrlScript`""

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $PowerShellPath
$Shortcut.Arguments = $ShortcutArguments
$Shortcut.IconLocation = "WindowsSandbox.exe"
$Shortcut.Hotkey = $Hotkey
$Shortcut.Save()

# Start Menu shortcut for more reliable hotkey registration
$StartMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Sandbox Quick Open"
New-Item -ItemType Directory -Path $StartMenuDir -Force | Out-Null

$StartMenuShortcutPath = Join-Path $StartMenuDir $ShortcutName

$StartMenuShortcut = $WScriptShell.CreateShortcut($StartMenuShortcutPath)
$StartMenuShortcut.TargetPath = $PowerShellPath
$StartMenuShortcut.Arguments = $ShortcutArguments
$StartMenuShortcut.IconLocation = "WindowsSandbox.exe"
$StartMenuShortcut.Hotkey = $Hotkey
$StartMenuShortcut.Save()

# Native Messaging Host manifest for Chromium browsers
if (Test-Path -LiteralPath $NativeHostCmd) {
    $NativeHostManifest = [ordered]@{
        name = $NativeHostName
        description = "Sandbox Quick Open Native Messaging Host"
        path = $NativeHostCmd
        type = "stdio"
        allowed_origins = @(
            "chrome-extension://$ChromiumExtensionId/"
        )
    }

    $NativeHostManifest |
        ConvertTo-Json -Depth 10 |
        Set-Content -Path $NativeHostManifestPath -Encoding UTF8

    # Chrome native host registry
    $ChromeNativeHostRegPath = "Software\Google\Chrome\NativeMessagingHosts\$NativeHostName"
    $RegKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($ChromeNativeHostRegPath)
    $RegKey.SetValue("", $NativeHostManifestPath, [Microsoft.Win32.RegistryValueKind]::String)
    $RegKey.Close()

    # Edge native host registry
    $EdgeNativeHostRegPath = "Software\Microsoft\Edge\NativeMessagingHosts\$NativeHostName"
    $RegKey = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($EdgeNativeHostRegPath)
    $RegKey.SetValue("", $NativeHostManifestPath, [Microsoft.Win32.RegistryValueKind]::String)
    $RegKey.Close()
}

Write-Host ""
Write-Host "Sandbox Quick Open installed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Installed to:"
Write-Host "  $InstallDir"
Write-Host ""
Write-Host "Context menu:"
Write-Host "  $MenuName"
Write-Host ""
Write-Host "Clipboard URL shortcut:"
Write-Host "  $ShortcutPath"
Write-Host "Start Menu shortcut:"
Write-Host "  $StartMenuShortcutPath"
Write-Host ""
Write-Host "Hotkey:"
Write-Host "  $Hotkey"
Write-Host ""
Write-Host "Browser integration:"
Write-Host "  Chromium extension ID: $ChromiumExtensionId"
Write-Host "  Native host: $NativeHostName"
Write-Host "  Native host manifest: $NativeHostManifestPath"
Write-Host ""
Write-Host "Usage:"
Write-Host "  Right-click a file or folder -> Open in Windows Sandbox"
Write-Host "  Copy a URL -> Press CTRL + ALT + S"
Write-Host "  Chrome/Edge extension -> Right-click a link -> Open Link in Windows Sandbox"
Write-Host ""