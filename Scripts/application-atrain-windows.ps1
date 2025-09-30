$LOGFILE = "C:\logs\application-atrain-windows.log"

Function Write-Log([String] $logText) {
    '{0:u}: {1}' -f (Get-Date), $logText | Out-File $LOGFILE -Append
}

Function Main {

    Write-Log "Define the URL for the aTrain installer"
    $installerUrl = "https://bandas.uni-graz.at/downloads/aTrain_v1.3.0.msix"

    Write-Log "Define the path where the installer will be downloaded"
    $installerPath = "C:\src-scripts\aTrain_v1.3.0.msix"  

    try {
        $wc = New-Object System.Net.WebClient
        Write-Log "Download file setup"
        $wc.DownloadFile($installerUrl , $installerPath)
        Write-Log "Download completed: $installerPath"
    }
    catch {
        Write-Log "ERROR during download: $($_.Exception.Message)"
        exit 1
    }

    try {
        Write-Log "Installing aTrain..."
        Add-AppxPackage -Path $installerPath -ErrorAction Stop
        Write-Log "Installation completed successfully."
    }
    catch {
        Write-Log "ERROR during installation: $($_.Exception.Message)"
        exit 1
    }

    try {
        Remove-Item -Path $installerPath -Force
        Write-Log "Installer file removed: $installerPath"
    }
    catch {
        Write-Log "Could not remove installer file: $($_.Exception.Message)"
    }
}

Main
