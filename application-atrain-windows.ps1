# ===================
# aTrain MSIX Install
# ===================

$basePath = "C:\src-scripts"
$LOGFILE = Join-Path $basePath "application-atrain-windows.log"
$installerUrl = "https://bandas.uni-graz.at/downloads/aTrain_v1.3.0.msix"
$installerPath = Join-Path $basePath "aTrain_v1.3.0.msix"
$extractPath = Join-Path $basePath "aTrain"

# -----------------------
# Logging function
# -----------------------
Function Write-Log([String] $logText) {
    '{0:u}: {1}' -f (Get-Date), $logText | Out-File $LOGFILE -Append
}

# -----------------------
# Main logic
# -----------------------
Function Main {

    # Ensure directories exist
    foreach ($path in @($basePath)) {
        if (!(Test-Path $path)) {
            New-Item -ItemType Directory -Path $path | Out-Null
        }
    }

    Write-Log "Starting aTrain installation script..."

    # --- Download installer ---
    Write-Log "Downloading aTrain installer from $installerUrl ..."
    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
        Write-Log "Download completed: $installerPath"
    } catch {
        Write-Log "ERROR: Failed to download installer. $_"
        return
    }

    # --- Try MSIX installation ---
    Write-Log "Checking if Add-AppxPackage is available..."
    $addAppxAvailable = Get-Command Add-AppxPackage -ErrorAction SilentlyContinue

    if ($addAppxAvailable) {
        Write-Log "Attempting to install aTrain using Add-AppxPackage (user scope)..."
        try {
            Add-AppxPackage -Path $installerPath -ForceApplicationShutdown -ErrorAction Stop
            Write-Log "SUCCESS: aTrain installation completed successfully via Add-AppxPackage."
        } catch {
            Write-Log "WARNING: aTrain installation failed via Add-AppxPackage. $_"
            Write-Log "Falling back to manual extraction..."
            ManualExtract
        }
    }
    else {
        Write-Log "Add-AppxPackage not available. Falling back to manual extraction..."
        ManualExtract
    }

    # --- Cleanup ---
    Write-Log "Cleaning up installer file..."
    try {
        Remove-Item -Path $installerPath -Force
        Write-Log "Installer removed successfully."
    } catch {
        Write-Log "WARNING: Could not remove installer file. $_"
    }

    Write-Log "Script completed."
}

# -----------------------
# Manual extraction fallback
# -----------------------
Function ManualExtract {
    try {
        if (!(Test-Path $extractPath)) {
            New-Item -ItemType Directory -Path $extractPath | Out-Null
        }

        Expand-Archive -Path $installerPath -DestinationPath $extractPath -Force
        Write-Log "MSIX extracted successfully to $extractPath"
        Write-Log "Note: This is a manual extraction, not a full installation."
    } catch {
        Write-Log "ERROR: Failed to manually extract MSIX package. $_"
    }
}

# -----------------------
# Run main
# -----------------------
Main
