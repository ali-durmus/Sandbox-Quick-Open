$ErrorActionPreference = "Stop"

function Show-SandboxQuickOpenPopup {
    param(
        [string]$Message
    )

    $wshell = New-Object -ComObject WScript.Shell
    $wshell.Popup($Message, 1, "Sandbox Quick Open", 64) | Out-Null
}

$ClipboardText = Get-Clipboard

if ([string]::IsNullOrWhiteSpace($ClipboardText)) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        "Clipboard is empty.",
        "Sandbox Quick Open"
    ) | Out-Null
    exit 1
}

$Url = $ClipboardText.Trim()

if ($Url -notmatch '^https?://') {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        "Clipboard does not contain a valid http/https URL.`n`nClipboard content:`n$Url",
        "Sandbox Quick Open"
    ) | Out-Null
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OpenUrlScript = Join-Path $ScriptDir "Open-Url-InSandbox.ps1"

if (-not (Test-Path -LiteralPath $OpenUrlScript)) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        "Open-Url-InSandbox.ps1 was not found.",
        "Sandbox Quick Open"
    ) | Out-Null
    exit 1
}

Show-SandboxQuickOpenPopup -Message "Opening URL in Windows Sandbox..."

& $OpenUrlScript $Url