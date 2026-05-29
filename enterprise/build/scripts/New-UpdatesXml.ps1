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
$ExtensionVersion = $EnterpriseExtensionVersion
$CrxFileName = $EnterpriseExtensionCrxFileName

$OutputDir = Join-Path $ProjectRoot "enterprise\build\output"
$UpdatesXmlPath = Join-Path $OutputDir "updates.xml"

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$CleanBaseUrl = $BaseUrl.TrimEnd("/")
$CrxUrl = "$CleanBaseUrl/$CrxFileName"

$XmlContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<gupdate xmlns="http://www.google.com/update2/response" protocol="2.0">
  <app appid="$ExtensionId">
    <updatecheck codebase="$CrxUrl" version="$ExtensionVersion" />
  </app>
</gupdate>
"@

Set-Content -Path $UpdatesXmlPath -Value $XmlContent -Encoding UTF8

Write-Host ""
Write-Host "updates.xml created successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Extension ID:"
Write-Host "  $ExtensionId"
Write-Host ""
Write-Host "CRX URL:"
Write-Host "  $CrxUrl"
Write-Host ""
Write-Host "updates.xml:"
Write-Host "  $UpdatesXmlPath"
Write-Host ""
Write-Host "GPO ExtensionInstallForcelist value:"
Write-Host "  $ExtensionId;$CleanBaseUrl/updates.xml"
Write-Host ""