param(
    [Parameter(Mandatory=$true)]
    [string]$BaseUrl
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$ConfigPath = Join-Path $ProjectRoot "enterprise\enterprise-config.ps1"

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Enterprise config file not found: $ConfigPath"
}

. $ConfigPath

$ExtensionId = $EnterpriseExtensionId

$GpoDir = Join-Path $ProjectRoot "enterprise\gpo"
$RegPath = Join-Path $GpoDir "edge-extension-force-install.reg"

New-Item -ItemType Directory -Path $GpoDir -Force | Out-Null

$CleanBaseUrl = $BaseUrl.TrimEnd("/")
$UpdateXmlUrl = "$CleanBaseUrl/updates.xml"
$PolicyValue = "$ExtensionId;$UpdateXmlUrl"

$RegContent = @"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist]
"1"="$PolicyValue"
"@

Set-Content -Path $RegPath -Value $RegContent -Encoding Unicode

Write-Host ""
Write-Host "Edge force-install registry file created successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Registry file:"
Write-Host "  $RegPath"
Write-Host ""
Write-Host "ExtensionInstallForcelist value:"
Write-Host "  $PolicyValue"
Write-Host ""