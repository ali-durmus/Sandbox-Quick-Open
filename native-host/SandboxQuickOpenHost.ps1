$ErrorActionPreference = "Stop"

function Read-NativeMessage {
    $stdin = [Console]::OpenStandardInput()

    $lengthBytes = New-Object byte[] 4
    $bytesRead = $stdin.Read($lengthBytes, 0, 4)

    if ($bytesRead -ne 4) {
        return $null
    }

    $messageLength = [BitConverter]::ToInt32($lengthBytes, 0)

    if ($messageLength -le 0) {
        return $null
    }

    $messageBytes = New-Object byte[] $messageLength
    $offset = 0

    while ($offset -lt $messageLength) {
        $read = $stdin.Read($messageBytes, $offset, $messageLength - $offset)
        if ($read -le 0) {
            break
        }
        $offset += $read
    }

    $json = [System.Text.Encoding]::UTF8.GetString($messageBytes)
    return $json | ConvertFrom-Json
}

function Write-NativeMessage {
    param(
        [object]$Message
    )

    $json = $Message | ConvertTo-Json -Compress
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $lengthBytes = [BitConverter]::GetBytes($bytes.Length)

    $stdout = [Console]::OpenStandardOutput()
    $stdout.Write($lengthBytes, 0, 4)
    $stdout.Write($bytes, 0, $bytes.Length)
    $stdout.Flush()
}

try {
    $Message = Read-NativeMessage

    if ($null -eq $Message) {
        Write-NativeMessage @{
            success = $false
            error = "No message received."
        }
        exit 1
    }

    if ($Message.action -ne "openUrl") {
        Write-NativeMessage @{
            success = $false
            error = "Unsupported action."
        }
        exit 1
    }

    $Url = [string]$Message.url

    if ($Url -notmatch '^https?://') {
        Write-NativeMessage @{
            success = $false
            error = "Only http and https URLs are supported."
        }
        exit 1
    }

    $OpenUrlScript = Join-Path $env:LOCALAPPDATA "Sandbox Quick Open\Open-Url-InSandbox.ps1"

    if (-not (Test-Path -LiteralPath $OpenUrlScript)) {
        Write-NativeMessage @{
            success = $false
            error = "Open-Url-InSandbox.ps1 was not found."
        }
        exit 1
    }

    Start-Process -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$OpenUrlScript`" `"$Url`"" `
        -WindowStyle Hidden

    Write-NativeMessage @{
        success = $true
        message = "URL sent to Windows Sandbox."
    }
}
catch {
    Write-NativeMessage @{
        success = $false
        error = $_.Exception.Message
    }
    exit 1
}