param(
    [Parameter(Mandatory=$false)]
    [string]$TargetPath = "C:\inetpub\wwwroot\sandboxquickopen",

    [Parameter(Mandatory=$false)]
    [string]$BaseUrl = "https://intranet.example.local/sandboxquickopen"
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExtensionSourceDir = Join-Path $ProjectRoot "enterprise\deployment-package\extension"

$CrxSource = Join-Path $ExtensionSourceDir "sandbox-quick-open-edge.crx"
$UpdatesXmlSource = Join-Path $ExtensionSourceDir "updates.xml"

Write-Host ""
Write-Host "Setting up IIS extension hosting files..." -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -LiteralPath $ExtensionSourceDir)) {
    throw "Extension source directory not found: $ExtensionSourceDir"
}

if (-not (Test-Path -LiteralPath $CrxSource)) {
    throw "CRX file not found: $CrxSource"
}

if (-not (Test-Path -LiteralPath $UpdatesXmlSource)) {
    throw "updates.xml file not found: $UpdatesXmlSource"
}

New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null

Copy-Item -LiteralPath $CrxSource -Destination (Join-Path $TargetPath "sandbox-quick-open-edge.crx") -Force
Copy-Item -LiteralPath $UpdatesXmlSource -Destination (Join-Path $TargetPath "updates.xml") -Force

Write-Host "Files copied successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Target path:"
Write-Host "  $TargetPath"
Write-Host ""
Write-Host "Expected URLs:"
Write-Host "  $BaseUrl/sandbox-quick-open-edge.crx"
Write-Host "  $BaseUrl/updates.xml"
Write-Host ""

# Optional IIS MIME type setup
try {
    Import-Module WebAdministration -ErrorAction Stop

    $MimeMapPath = "IIS:\Sites\Default Web Site\sandboxquickopen"

    Write-Host "IIS WebAdministration module found." -ForegroundColor Green
    Write-Host "Checking MIME types..." -ForegroundColor Cyan

    $existingCrxMime = Get-WebConfigurationProperty `
        -Filter "system.webServer/staticContent/mimeMap[@fileExtension='.crx']" `
        -PSPath "IIS:\Sites\Default Web Site" `
        -Name "." `
        -ErrorAction SilentlyContinue

    if (-not $existingCrxMime) {
        Add-WebConfigurationProperty `
            -PSPath "IIS:\Sites\Default Web Site" `
            -Filter "system.webServer/staticContent" `
            -Name "." `
            -Value @{ fileExtension = ".crx"; mimeType = "application/x-chrome-extension" }

        Write-Host "Added MIME type for .crx" -ForegroundColor Green
    }
    else {
        Write-Host ".crx MIME type already exists." -ForegroundColor Yellow
    }

    $existingXmlMime = Get-WebConfigurationProperty `
        -Filter "system.webServer/staticContent/mimeMap[@fileExtension='.xml']" `
        -PSPath "IIS:\Sites\Default Web Site" `
        -Name "." `
        -ErrorAction SilentlyContinue

    if (-not $existingXmlMime) {
        Add-WebConfigurationProperty `
            -PSPath "IIS:\Sites\Default Web Site" `
            -Filter "system.webServer/staticContent" `
            -Name "." `
            -Value @{ fileExtension = ".xml"; mimeType = "application/xml" }

        Write-Host "Added MIME type for .xml" -ForegroundColor Green
    }
    else {
        Write-Host ".xml MIME type already exists." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "IIS WebAdministration module was not available or IIS is not installed." -ForegroundColor Yellow
    Write-Host "Files were copied, but IIS MIME types were not configured automatically."
    Write-Host "If using IIS, make sure .crx is served as:"
    Write-Host "  application/x-chrome-extension"
    Write-Host "and .xml is served as:"
    Write-Host "  application/xml"
}

Write-Host ""
Write-Host "IIS hosting preparation completed." -ForegroundColor Green
Write-Host ""