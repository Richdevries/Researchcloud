$LOGFILE = "C:\logs\application-atrain-windows.log"

Function Write-Log([String] $logText) {
    '{0:u}: {1}' -f (Get-Date), $logText | Out-File $LOGFILE -Append
}

Function Main {

    Write-Log "Define the URL for the aTrain installer"
    $installerUrl = "https://bandas.uni-graz.at/downloads/aTrain_v1.3.0.msix"

    Write-Log "Define the path where the installer will be downloaded"
    $installerPath = "C:\src-scripts\aTrain_v1.3.0.msix"
    $extractPath   = "C:\Program Files\aTrain"

    # Download the installer
    $wc = New-Object System.Net.WebClient
    Write-Log "Downloading aTrain installer..."
    try {
        $wc.DownloadFile($installerUrl, $installerPath)
        Write-Log "Download completed: $installerPath"
    } catch {
        Write-Log "ERROR: Failed to download installer. $_"
        return
    }

    # Check if Add-AppxPackage is available
    Write-Log "Checking if Add-AppxPackage is available..."
    $addAppxAvailable = Get-Command Add-AppxPackage -ErrorAction SilentlyContinue

    if ($addAppxAvailable) {
        Write-Log "Installing aTrain via Add-AppxPackage..."
        try {
            Add-AppxPackage -Path $installerPath -ForceApplicationShutdown
            Write-Log "aTrain installation completed successfully."
        } catch {
            Write-Log "ERROR: aTrain installation failed via Add-AppxPackage. $_"
        }
    }
    else {
        Write-Log "Add-AppxPackage not available. Extracting MSIX manually..."
        try {
            if (!(Test-Path $extractPath)) {
                New-Item -ItemType Directory -Path $extractPath | Out-Null
            }

            # Use PowerShell's built-in Expand-Archive to extract MSIX (it's a ZIP container)
            Expand-Archive -Path $installerPath -DestinationPath $extractPath -Force
            Write-Log "aTrain files extracted to $extractPath"

            # Optional: create a shortcut or register app manually here
        } catch {
            Write-Log "ERROR: Failed to extract MSIX package manually. $_"
        }
    }

    # Clean up
    Write-Log "Removing installer file..."
    try {
        Remove-Item -Path $installerPath -Force
        Write-Log "Installer removed."
    } catch {
        Write-Log "Warning: Could not remove installer file. $_"
    }
}

Main
