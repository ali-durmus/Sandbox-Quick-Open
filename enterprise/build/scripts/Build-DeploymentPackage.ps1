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
$ClientDir = Join-Path $PackageRoot "client"
$ExtensionDir = Join-Path $PackageRoot "extension"
$GpoDir = Join-Path $PackageRoot "gpo"

$BuildOutputDir = Join-Path $ProjectRoot "enterprise\build\output"

Write-Host ""
Write-Host "Building enterprise deployment package..." -ForegroundColor Cyan
Write-Host ""

# Clean package directories
if (Test-Path -LiteralPath $PackageRoot) {
    Remove-Item -LiteralPath $PackageRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $ClientDir -Force | Out-Null
New-Item -ItemType Directory -Path $ExtensionDir -Force | Out-Null
New-Item -ItemType Directory -Path $GpoDir -Force | Out-Null

# Rebuild updates.xml with provided BaseUrl
$UpdatesScript = Join-Path $ProjectRoot "enterprise\build\scripts\New-UpdatesXml.ps1"

if (-not (Test-Path -LiteralPath $UpdatesScript)) {
    throw "Updates XML script not found: $UpdatesScript"
}

& $UpdatesScript -BaseUrl $BaseUrl
# Rebuild Edge force-install registry file with provided BaseUrl
$EdgeForceInstallRegScript = Join-Path $ProjectRoot "enterprise\build\scripts\New-EdgeForceInstallReg.ps1"

if (-not (Test-Path -LiteralPath $EdgeForceInstallRegScript)) {
    throw "Edge force-install registry script not found: $EdgeForceInstallRegScript"
}

& $EdgeForceInstallRegScript -BaseUrl $BaseUrl
# Client files
$ClientSources = @(
    "src\Open-InSandbox.ps1",
    "src\Open-Url-InSandbox.ps1",
    "src\Open-ClipboardUrl-InSandbox.ps1",
    "native-host\SandboxQuickOpenHost.ps1",
    "native-host\SandboxQuickOpenHost.cmd",
    "enterprise\gpo\com.sandboxquickopen.host.json",
    "enterprise\scripts\deploy-client.ps1",
    "enterprise\scripts\remove-client.ps1",
    "enterprise\scripts\enable-windows-sandbox.ps1",
    "enterprise\scripts\Setup-IisExtensionHosting.ps1"
)

foreach ($RelativePath in $ClientSources) {
    $SourcePath = Join-Path $ProjectRoot $RelativePath

    if (-not (Test-Path -LiteralPath $SourcePath)) {
        throw "Required file not found: $SourcePath"
    }

    Copy-Item -LiteralPath $SourcePath -Destination $ClientDir -Force
}

# Extension files
$ExtensionSources = @(
    "sandbox-quick-open-edge.crx",
    "updates.xml"
)

foreach ($FileName in $ExtensionSources) {
    $SourcePath = Join-Path $BuildOutputDir $FileName

    if (-not (Test-Path -LiteralPath $SourcePath)) {
        throw "Required extension file not found: $SourcePath"
    }

    Copy-Item -LiteralPath $SourcePath -Destination $ExtensionDir -Force
}

$GpoSources = @(
    "enterprise\gpo\edge-extension-force-install.reg",
    "enterprise\gpo\edge-native-host.reg",
    "enterprise\gpo\com.sandboxquickopen.host.json"
)

foreach ($RelativePath in $GpoSources) {
    $SourcePath = Join-Path $ProjectRoot $RelativePath

    if (-not (Test-Path -LiteralPath $SourcePath)) {
        throw "Required GPO file not found: $SourcePath"
    }

    Copy-Item -LiteralPath $SourcePath -Destination $GpoDir -Force
}
# Create deployment notes
$NotesPath = Join-Path $PackageRoot "DEPLOYMENT-NOTES.txt"
$ExtensionId = $EnterpriseExtensionId
$CleanBaseUrl = $BaseUrl.TrimEnd("/")
$ExtensionInstallForcelistValue = "$ExtensionId;$CleanBaseUrl/updates.xml"

$NotesContent = @"
Sandbox Quick Open - Enterprise Deployment Notes

Current enterprise extension ID:
$ExtensionId

Current Base URL:
$CleanBaseUrl

Edge ExtensionInstallForcelist value:
$ExtensionInstallForcelistValue


1. Extension hosting

Copy these files to your internal web server / IIS / intranet path:

extension\sandbox-quick-open-edge.crx
extension\updates.xml

The files must be reachable by Edge clients, for example:

$CleanBaseUrl/sandbox-quick-open-edge.crx
$CleanBaseUrl/updates.xml


2. Client deployment

Deploy the client files to each workstation.

Recommended target path:

C:\Program Files\Sandbox Quick Open

Use this script as Computer Startup Script or software deployment script:

client\deploy-client.ps1

This script installs:

- PowerShell launcher scripts
- Native Messaging Host files
- Native Messaging Host manifest
- File/folder context menu entries
- Edge Native Messaging Host registry entry


3. Windows Sandbox feature

If Windows Sandbox is not enabled on client machines, run:

client\enable-windows-sandbox.ps1

A restart may be required.


4. Edge GPO policy

Configure Microsoft Edge ExtensionInstallForcelist.

Registry path:

HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist

Value:

Name:
1

Type:
REG_SZ

Data:
$ExtensionInstallForcelistValue


5. Native Messaging Host registry

The deploy-client.ps1 script already creates this registry entry:

HKLM\SOFTWARE\Microsoft\Edge\NativeMessagingHosts\com.sandboxquickopen.host

Default value:

C:\Program Files\Sandbox Quick Open\com.sandboxquickopen.host.json


6. Native host manifest

The native host manifest must allow the enterprise extension ID:

chrome-extension://$ExtensionId/

Manifest path:

C:\Program Files\Sandbox Quick Open\com.sandboxquickopen.host.json


7. User experience

After deployment:

- Users can right-click files and folders:
  Open in Windows Sandbox

- Users can right-click links in Microsoft Edge:
  Open Link in Windows Sandbox

- Suspicious links open inside Windows Sandbox.


8. Removal

To remove the client files and registry entries from a workstation, run:

client\remove-client.ps1

This does not remove the Edge force-install policy.
Remove or disable the related GPO policy separately.


9. Important notes

- Keep the PEM private key safe:
  enterprise\build\keys\sandbox-quick-open-edge.pem

- Do not regenerate the PEM unless you intentionally want a new extension ID.

- If the extension version changes, rebuild:
  enterprise\build\scripts\Build-EdgeExtension.ps1
  enterprise\build\scripts\New-UpdatesXml.ps1
  enterprise\build\scripts\Build-DeploymentPackage.ps1
"@

Set-Content -Path $NotesPath -Value $NotesContent -Encoding UTF8
Write-Host ""
Write-Host "Enterprise deployment package created successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Package root:"
Write-Host "  $PackageRoot"
Write-Host ""
Write-Host "Client files:"
Write-Host "  $ClientDir"
Write-Host ""
Write-Host "Extension files:"
Write-Host "  $ExtensionDir"
Write-Host ""
Write-Host "GPO files:"
Write-Host "  $GpoDir"
Write-Host ""
Write-Host "Base URL:"
Write-Host "  $BaseUrl"
Write-Host ""
Write-Host "GPO ExtensionInstallForcelist value:"
Write-Host "$EnterpriseExtensionId;$BaseUrl/updates.xml"
Write-Host ""