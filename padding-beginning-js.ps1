param( 
    [Parameter(Mandatory = $true)]
    [string]$InputFile
)

if (-not (Test-Path $InputFile)) {
    Write-Error "File not found: $InputFile"
    exit
}

Write-Host "Reading original file..."
$originalContent = Get-Content $InputFile -Raw
$outputBaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$extension = [System.IO.Path]::GetExtension($InputFile)
$directory = Split-Path $InputFile
if ([string]::IsNullOrWhiteSpace($directory)) { $directory = "." }

$sizesMB = 1..8 | ForEach-Object { $_ * 5 }
$originalSizeBytes = [System.Text.Encoding]::ASCII.GetByteCount($originalContent)

function Get-RandomLowercaseLetters {
    param([int]$Length)

    $letters = 'abcdefghijklmnopqrstuvwxyz'
    $random = New-Object System.Random
    $sb = New-Object -TypeName System.Text.StringBuilder
    for ($i = 0; $i -lt $Length; $i++) {
        [void]$sb.Append($letters[$random.Next(0, $letters.Length)])
    }
    return $sb.ToString()
}

foreach ($sizeMB in $sizesMB) {
    Write-Host "Processing target size: ${sizeMB}MB..."

    $targetSizeBytes = $sizeMB * 1MB
    $commentHeader = "/* PADDING START`n"
    $commentFooter = "`nPADDING END */`n"
    $commentOverheadBytes = [System.Text.Encoding]::ASCII.GetByteCount($commentHeader + $commentFooter)
    $paddingSize = $targetSizeBytes - $originalSizeBytes - $commentOverheadBytes

    if ($paddingSize -le 0) {
        Write-Warning "Original file is already larger than $sizeMB MB, skipping..."
        continue
    }

    Write-Host "Generating random padding of $paddingSize bytes..."
    $fillerComment = Get-RandomLowercaseLetters -Length $paddingSize
    $paddedCommentBlock = $commentHeader + $fillerComment + $commentFooter
    $newContent = $paddedCommentBlock + $originalContent

    $outputFile = Join-Path $directory ("{0}_{1}MB_beginning{2}" -f $outputBaseName, $sizeMB, $extension)
    [System.IO.File]::WriteAllText($outputFile, $newContent, [System.Text.Encoding]::ASCII)

    $actualSize = (Get-Item $outputFile).Length
    Write-Host "Created: $outputFile with size: $actualSize bytes"
}
