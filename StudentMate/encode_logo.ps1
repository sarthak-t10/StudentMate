# Run this script ONCE after saving the logo image.
# Usage: powershell -ExecutionPolicy Bypass -File encode_logo.ps1
# It reads assets/images/student_mate_logo.png and writes
# lib/utils/logo_data.dart with the base64-encoded bytes.

$inputPath = "$PSScriptRoot\assets\images\student_mate_logo.png"
$outputPath = "$PSScriptRoot\lib\utils\logo_data.dart"

if (-not (Test-Path $inputPath)) {
    Write-Host "ERROR: Image not found at $inputPath"
    Write-Host "Please save the StudentMate logo as: assets/images/student_mate_logo.png"
    exit 1
}

$bytes = [System.IO.File]::ReadAllBytes($inputPath)
$b64  = [System.Convert]::ToBase64String($bytes)

$dart = @"
// AUTO-GENERATED — do not edit manually.
// Run encode_logo.ps1 to regenerate after changing the logo image.
const String kLogoBase64 = '$b64';
"@

$dart | Set-Content -Path $outputPath -Encoding UTF8
Write-Host "Done! logo_data.dart written to $outputPath"
Write-Host "Now run: flutter run -d windows"
