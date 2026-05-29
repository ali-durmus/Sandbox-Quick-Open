$ErrorActionPreference = "Stop"

$InstallDir = "C:\Program Files\Sandbox Quick Open"
$PowerShellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$SourceDir = Join-Path $ProjectRoot "src"
$NativeHostDir = Join-Path $ProjectRoot "native-host"
$EnterpriseGpoDir = Join-Path $ProjectRoot "enterprise\gpo"

$NativeHostName = "com.sandboxquickopen.host"

Write-Host ""
Write-Host "Deploying Sandbox Quick Open enterprise client..." -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -LiteralPath $PowerShellPath)) {
    throw "Windows PowerShell was not found at: $PowerShellPath"
}

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

$FilesToCopy = @(
    @{
        Source = Join-Path $SourceDir "Open-InSandbox.ps1"
        Target = Join-Path $InstallDir "Open-InSandbox.ps1"
    },
    @{
        Source = Join-Path $SourceDir "Open-Url-InSandbox.ps1"
        Target = Join-Path $InstallDir "Open-Url-InSandbox.ps1"
    },
    @{
        Source = Join-Path $SourceDir "Open-ClipboardUrl-InSandbox.ps1"
        Target = Join-Path $InstallDir "Open-ClipboardUrl-InSandbox.ps1"
    },
    @{
        Source = Join-Path $NativeHostDir "SandboxQuickOpenHost.ps1"
        Target = Join-Path $InstallDir "SandboxQuickOpenHost.ps1"
    },
    @{
        Source = Join-Path $NativeHostDir "SandboxQuickOpenHost.cmd"
        Target = Join-Path $InstallDir "SandboxQuickOpenHost.cmd"
    },
    @{
        Source = Join-Path $EnterpriseGpoDir "com.sandboxquickopen.host.json"
        Target = Join-Path $InstallDir "com.sandboxquickopen.host.json"
    }
)

foreach ($File in $FilesToCopy) {
    if (-not (Test-Path -LiteralPath $File.Source)) {
        throw "Required source file not found: $($File.Source)"
    }

    Copy-Item -LiteralPath $File.Source -Destination $File.Target -Force
}

# File/folder context menu for all users via HKLM
$MenuName = "Open in Windows Sandbox"
$OpenInSandboxScript = Join-Path $InstallDir "Open-InSandbox.ps1"
$CommandValue = '"' + $PowerShellPath + '" -ExecutionPolicy Bypass -File "' + $OpenInSandboxScript + '" "%1"'

$FileMenuRegPath = "Software\Classes\*\shell\OpenInWindowsSandbox"
$FileCommandRegPath = "Software\Classes\*\shell\OpenInWindowsSandbox\command"

$RegKey = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($FileMenuRegPath)
$RegKey.SetValue("", $MenuName, [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.SetValue("Icon", "WindowsSandbox.exe", [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.Close()

$RegKey = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($FileCommandRegPath)
$RegKey.SetValue("", $CommandValue, [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.Close()

$DirectoryMenuRegPath = "Software\Classes\Directory\shell\OpenInWindowsSandbox"
$DirectoryCommandRegPath = "Software\Classes\Directory\shell\OpenInWindowsSandbox\command"

$RegKey = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($DirectoryMenuRegPath)
$RegKey.SetValue("", $MenuName, [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.SetValue("Icon", "WindowsSandbox.exe", [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.Close()

$RegKey = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($DirectoryCommandRegPath)
$RegKey.SetValue("", $CommandValue, [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.Close()

# Edge Native Messaging Host registry
$NativeHostManifestPath = Join-Path $InstallDir "$NativeHostName.json"
$EdgeNativeHostRegPath = "Software\Microsoft\Edge\NativeMessagingHosts\$NativeHostName"

$RegKey = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($EdgeNativeHostRegPath)
$RegKey.SetValue("", $NativeHostManifestPath, [Microsoft.Win32.RegistryValueKind]::String)
$RegKey.Close()

Write-Host "Deployment completed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Installed to:"
Write-Host "  $InstallDir"
Write-Host ""
Write-Host "Context menu:"
Write-Host "  $MenuName"
Write-Host ""
Write-Host "Edge Native Messaging Host:"
Write-Host "  $NativeHostName"
Write-Host ""
Write-Host "Native host manifest:"
Write-Host "  $NativeHostManifestPath"
Write-Host ""
Write-Host "Note:"
Write-Host "  Edge extension force-install policy must be configured separately via GPO."
Write-Host ""