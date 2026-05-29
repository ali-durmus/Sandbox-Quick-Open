param(
    [Parameter(Mandatory=$true)]
    [string]$Url
)

$ErrorActionPreference = "Stop"

if ($Url -notmatch '^https?://') {
    throw "Only http and https URLs are supported. Received: $Url"
}

$BaseDir = Join-Path $env:TEMP "SandboxQuickOpen"
$SessionId = [guid]::NewGuid().ToString()
$SessionDir = Join-Path $BaseDir $SessionId

New-Item -ItemType Directory -Path $SessionDir -Force | Out-Null

$InsideScriptPath = Join-Path $SessionDir "RunUrlInsideSandbox.ps1"

$InsideScript = @"
Start-Sleep -Seconds 2
Start-Process "msedge.exe" "$Url"
"@

Set-Content -Path $InsideScriptPath -Value $InsideScript -Encoding UTF8

$WsbPath = Join-Path $SessionDir "OpenUrlInSandbox.wsb"

$WsbContent = @"
<Configuration>
  <Networking>Default</Networking>
  <ClipboardRedirection>Disable</ClipboardRedirection>
  <PrinterRedirection>Disable</PrinterRedirection>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>$SessionDir</HostFolder>
      <SandboxFolder>C:\Users\WDAGUtilityAccount\Desktop\SandboxConfig</SandboxFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
  </MappedFolders>
  <LogonCommand>
    <Command>powershell.exe -ExecutionPolicy Bypass -File "C:\Users\WDAGUtilityAccount\Desktop\SandboxConfig\RunUrlInsideSandbox.ps1"</Command>
  </LogonCommand>
</Configuration>
"@

Set-Content -Path $WsbPath -Value $WsbContent -Encoding UTF8

Start-Process $WsbPath