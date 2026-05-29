$ErrorActionPreference = "Stop"

function Encode-Asn1Length {
    param([int]$Length)

    if ($Length -lt 128) {
        return [byte[]]@($Length)
    }

    $bytes = New-Object System.Collections.Generic.List[byte]
    $value = $Length

    while ($value -gt 0) {
        $bytes.Insert(0, [byte]($value -band 0xFF))
        $value = $value -shr 8
    }

    return [byte[]](@(0x80 -bor $bytes.Count) + $bytes.ToArray())
}

function Encode-Asn1Integer {
    param([byte[]]$Bytes)

    while ($Bytes.Length -gt 1 -and $Bytes[0] -eq 0x00) {
        $Bytes = $Bytes[1..($Bytes.Length - 1)]
    }

    if (($Bytes[0] -band 0x80) -ne 0) {
        $Bytes = [byte[]]@(0x00) + $Bytes
    }

    $length = Encode-Asn1Length $Bytes.Length
    return [byte[]](@(0x02) + $length + $Bytes)
}

function Encode-Asn1Sequence {
    param([byte[]]$Content)

    $length = Encode-Asn1Length $Content.Length
    return [byte[]](@(0x30) + $length + $Content)
}

function Encode-Asn1BitString {
    param([byte[]]$Content)

    $withUnusedBits = [byte[]]@(0x00) + $Content
    $length = Encode-Asn1Length $withUnusedBits.Length
    return [byte[]](@(0x03) + $length + $withUnusedBits)
}

function Convert-ToChromeExtensionId {
    param([byte[]]$PublicKeyDer)

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hash = $sha256.ComputeHash($PublicKeyDer)

    $id = ""
    for ($i = 0; $i -lt 16; $i++) {
        $byte = $hash[$i]
        $high = ($byte -shr 4) -band 0x0F
        $low = $byte -band 0x0F

        $id += [char]([int][char]'a' + $high)
        $id += [char]([int][char]'a' + $low)
    }

    return $id
}

# Generate RSA key
$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider 2048
$params = $rsa.ExportParameters($false)

# RSAPublicKey ::= SEQUENCE { modulus INTEGER, publicExponent INTEGER }
$modulus = Encode-Asn1Integer $params.Modulus
$exponent = Encode-Asn1Integer $params.Exponent
$rsaPublicKey = Encode-Asn1Sequence ([byte[]]($modulus + $exponent))

# AlgorithmIdentifier for rsaEncryption OID 1.2.840.113549.1.1.1 + NULL
$algorithmIdentifier = [byte[]]@(
    0x30, 0x0D,
    0x06, 0x09,
    0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01,
    0x05, 0x00
)

# SubjectPublicKeyInfo ::= SEQUENCE { algorithm AlgorithmIdentifier, subjectPublicKey BIT STRING }
$subjectPublicKey = Encode-Asn1BitString $rsaPublicKey
$subjectPublicKeyInfo = Encode-Asn1Sequence ([byte[]]($algorithmIdentifier + $subjectPublicKey))

$manifestKey = [Convert]::ToBase64String($subjectPublicKeyInfo)
$extensionId = Convert-ToChromeExtensionId $subjectPublicKeyInfo

$outDir = Join-Path (Split-Path -Parent $PSScriptRoot) "browser-extension\chromium"
$outFile = Join-Path $outDir "extension-key.txt"

@"
Extension ID:
$extensionId

Manifest key:
$manifestKey
"@ | Set-Content -Path $outFile -Encoding UTF8

Write-Host ""
Write-Host "Extension key generated." -ForegroundColor Green
Write-Host ""
Write-Host "Extension ID:"
Write-Host $extensionId
Write-Host ""
Write-Host "Manifest key saved to:"
Write-Host $outFile
Write-Host ""