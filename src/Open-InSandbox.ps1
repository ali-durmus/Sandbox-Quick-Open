param(
    [Parameter(Mandatory=$true)]
    [string]$TargetPath
)

$ErrorActionPreference = "Stop"

# Project/session base folder
$BaseDir = Join-Path $env:TEMP "SandboxQuickOpen"
$SessionId = [guid]::NewGuid().ToString()
$SessionDir = Join-Path $BaseDir $SessionId
$InputDir = Join-Path $SessionDir "Input"

New-Item -ItemType Directory -Path $InputDir -Force | Out-Null

# Validate target
if (-not (Test-Path -LiteralPath $TargetPath)) {
    throw "Target path not found: $TargetPath"
}

$Item = Get-Item -LiteralPath $TargetPath
$ItemName = $Item.Name
$CopiedItemPath = Join-Path $InputDir $ItemName

# Copy selected file or folder into temporary input folder
if ($Item.PSIsContainer) {
    Copy-Item -LiteralPath $TargetPath -Destination $CopiedItemPath -Recurse -Force
} else {
    Copy-Item -LiteralPath $TargetPath -Destination $CopiedItemPath -Force
}

# Script that runs inside Windows Sandbox
$InsideScriptPath = Join-Path $SessionDir "RunInsideSandbox.ps1"

$InsideScript = @"
`$WorkDir = "C:\Users\WDAGUtilityAccount\Desktop\SandboxWork"
`$HostInput = "C:\Users\WDAGUtilityAccount\Desktop\HostInput"
`$ItemName = "$ItemName"
`$SourcePath = Join-Path `$HostInput `$ItemName
`$DestinationPath = Join-Path `$WorkDir `$ItemName

New-Item -ItemType Directory -Path `$WorkDir -Force | Out-Null

Copy-Item -LiteralPath `$SourcePath -Destination `$DestinationPath -Recurse -Force

Start-Process explorer.exe `$WorkDir
"@

Set-Content -Path $InsideScriptPath -Value $InsideScript -Encoding UTF8

# Create WSB config
$WsbPath = Join-Path $SessionDir "OpenInSandbox.wsb"

$WsbContent = @"
<Configuration>
  <Networking>Default</Networking>
  <ClipboardRedirection>Disable</ClipboardRedirection>
  <PrinterRedirection>Disable</PrinterRedirection>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>$InputDir</HostFolder>
      <SandboxFolder>C:\Users\WDAGUtilityAccount\Desktop\HostInput</SandboxFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
    <MappedFolder>
      <HostFolder>$SessionDir</HostFolder>
      <SandboxFolder>C:\Users\WDAGUtilityAccount\Desktop\SandboxConfig</SandboxFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
  </MappedFolders>
  <LogonCommand>
    <Command>powershell.exe -ExecutionPolicy Bypass -File "C:\Users\WDAGUtilityAccount\Desktop\SandboxConfig\RunInsideSandbox.ps1"</Command>
  </LogonCommand>
</Configuration>
"@

Set-Content -Path $WsbPath -Value $WsbContent -Encoding UTF8

# Start Windows Sandbox
Start-Process $WsbPath