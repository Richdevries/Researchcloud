$ProgressPreference = 'SilentlyContinue'

function DownloadAtrain([string] $url, [string] $downloadLocation, [int] $retries)
{
    while($true)
    {
        try
        {
            Invoke-WebRequest $url -OutFile $downloadLocation
            break
        }
        catch
        {
            $exceptionMessage = $_.Exception.Message
            Write-Host "Failed to download '$url': $exceptionMessage"
            if ($retries -gt 0) {
                $retries--
                Write-Host "Waiting 10 seconds before retrying. Retries left: $retries"
                Start-Sleep -Seconds 10
            }
            else
            {
                throw $_.Exception
            }
        }
    }
}

try {
    New-Item "C:\downloads\Atrain" -ItemType Directory -Force
    DownloadAtrain -url "https://bandas.uni-graz.at/downloads/aTrain_v1.3.0.msix" -downloadLocation "C:\downloads\Atrain\aTrain_v1.3.0.msix" -retries 3
    Write-Host "Installeren van aTrain..."
    Add-AppxPackage -Path "C:\downloads\Atrain\aTrain_v1.3.0.msix"
    Write-Host "Installatie voltooid!"
} catch {
    Write-Host "aTrain installation has failed with the following error: $_"
    Throw "Aborted aTrain installation returned $_"
}
