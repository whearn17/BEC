.\Modules\Reload-Modules.ps1
Import-Module .\Modules\Logging\Logging.psm1
Import-Module .\Modules\Microsoft365\Authentication\M365Auth.ps1

function main {

    Write-ScreenLog -Message "Connecting to M365 Endpoints" -Level "info"
    Connect-M365
}

main