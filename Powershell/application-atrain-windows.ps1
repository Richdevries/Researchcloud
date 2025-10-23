# ===================
# aTrain MSIX Install
# ===================

$basePath = "C:\src-scripts"
$LOGFILE = Join-Path $basePath "application-atrain-windows.log"
$installerUrl = "https://bandas.uni-graz.at/downloads/aTrain_v1.3.0.msix"
$installerPath = Join-Path $basePath "aTrain_v1.3.0.msix"

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

    # Ensure base directory exists
    if (!(Test-Path $basePath)) {
        New-Item -ItemType Directory -Path $basePath | Out-Null
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

    # --- MSIX Installation ---
    Write-Log "Attempting to install aTrain using Add-AppxPackage..."
    try {
        Add-AppxPackage -Path $installerPath -ForceApplicationShutdown -ErrorAction Stop
        Write-Log "SUCCESS: aTrain installation completed successfully via Add-AppxPackage."
    } catch {
        Write-Log "ERROR: aTrain installation failed via Add-AppxPackage. $_"
        Write-Log "Script aborted due to installation failure."
        return
    }

    # --- Cleanup ---
    Write-Log "Cleaning up installer file..."
    try {
        Remove-Item -Path $installerPath -Force
        Write-Log "Installer removed successfully."
    } catch {
        Write-Log "WARNING: Could not remove installer file. $_"
    }

    Write-Log "Script completed successfully."
}

# -----------------------
# Run main
# -----------------------
Main
