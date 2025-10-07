$LOGFILE = "C:\logs\aTrain-install.log"

Function Write-Log([String] $logText) {
    '{0:u}: {1}' -f (Get-Date), $logText | Out-File $LOGFILE -Append
}

Function Main {
    Write-Log "Start aTrain installatie"

    try {
        # URL van de aTrain-installatie
        $url = "https://bandas.uni-graz.at/downloads/aTrain_v1.3.0.msix"
        $outpath = "$env:temp\aTrain_v1.3.0.msix"
        
        Write-Log "Download aTrain van $url naar $outpath"
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $outpath)

        Write-Log "Download voltooid. Start installatie..."
        Add-AppxPackage -Path $outpath -ForceApplicationShutdown -ErrorAction Stop

        Write-Log "aTrain succesvol geïnstalleerd."
    }
    catch {
        Write-Log "Fout tijdens installatie: $_"
        Throw $_
    }

    Write-Log "Einde aTrain installatie"
}

Main
