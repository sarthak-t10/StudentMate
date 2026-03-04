#!/usr/bin/env pwsh
# Kill any existing Flutter processes
$flutterProcesses = Get-Process flutter -ErrorAction SilentlyContinue
if ($flutterProcesses) {
    $flutterProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Navigate to project and run Flutter
cd "E:\Sarthak\mobileapp"

# Run flutter devices to list available devices
Write-Host "Available devices:"
flutter devices

# Run with explicit Edge device selection
Write-Host "Starting Flutter web app..."
flutter run -d edge --web-port=5001

