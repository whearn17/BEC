.\Modules\Reload-Modules.ps1
Import-Module .\Modules\Logging\Logging.psm1
Import-Module .\Modules\Microsoft365\Authentication\M365Auth.psm1
Import-Module .\Modules\Microsoft365\Collection\MailboxAuditLogs\Get-MailboxAuditLogs.psm1

function Get-AllMailboxAuditLogsSubroutine {
    param (
        [string[]]$UserPrincipalNames,
        [string]$DomainName
    )

    $ExchangeMailboxAuditLogs = @()

    foreach ($UserPrincipalName in $UserPrincipalNames) {
        $ExchangeMailboxAuditLogs += Get-AllMailboxAuditLogs -UserPrincipalName $UserPrincipalName -StartDate -EndDate # FILL THIS OUT
    }

    $ExchangeMailboxAuditLogs | Export-Csv -Path "$(Get-Location)\$($DomainName)" -NoTypeInformation
}

function main {

    Write-ConsoleLog -Message "Collector started" -Level "info"
    Out-FileLog -Message "Collector started" -Level "info"

    Write-ConsoleLog -Message "Connecting to M365 Endpoints" -Level "info"
    Out-FileLog -Message "Connecting to M365 Endpoints" -Level "info"
    Connect-M365

    [string]$TenantDomainName = (Get-AcceptedDomain | Where-Object { $_.Default -eq $true }).DomainName

    Write-ConsoleLog -Message "Gathering user principal name list from tenant" -Level "info"
    Out-FileLog -Message "Gathering user principal name list from tenant" -Level "info"
    [string[]]$AllUserPrincipalNames = Get-Mailbox -ResultSize Unlimited | Select-Object UserPrincipalName

    Write-ConsoleLog -Message "Gathering user mailbox audit logs" -Level "info"
    Out-FileLog -Message "Gathering user mailbox audit logs" -Level "info"
    Get-AllMailboxAuditLogsSubroutine -UserPrincipalNames $AllUserPrincipalNames -DomainName $TenantDomainName
}

main