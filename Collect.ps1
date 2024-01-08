.\Modules\ReloadModules.ps1
Import-Module .\Modules\Logging\Logging.psm1
Import-Module .\Modules\Microsoft365\Authentication\M365Auth.psm1
Import-Module .\Modules\Microsoft365\Collection\MailboxAuditLogs\MailboxAuditLogs.psm1
Import-Module .\Modules\Microsoft365\Collection\AuthenticationLogs\TenantAuthenticationLogs.psm1

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


    # Exchange Mailbox Audit Logs

    Write-ConsoleLog -Message "Gathering user mailbox audit logs" -Level "info"
    Out-FileLog -Message "Gathering user mailbox audit logs" -Level "info"
    Get-MailboxAuditLogs -UserPrincipalNames $AllUserPrincipalNames -DomainName $TenantDomainName -StartDate (Get-Date).AddDays(-90) -EndDate Get-Date

    # Unified Audit Logs

    $AuthenticationEvents = @("UserLoggedIn")
    $InboxRuleEvents = @("New-InboxRule", "Set-InboxRule", "Remove-InboxRule")

    Write-ConsoleLog -Message "Gathering user authentication logs" -Level "info"
    Out-FileLog -Message "Gathering user authentication logs" -Level "info"
    Get-AuditLogs -SearchStartDate (Get-Date).AddDays(-90) -EndDate Get-Date -EventTypes $AuthenticationEvents

    Write-ConsoleLog -Message "Gathering user inbox rule logs" -Level "info"
    Out-FileLog -Message "Gathering user inbox rule logs" -Level "info"
    Get-AuditLogs -SearchStartDate (Get-Date).AddDays(-90) -EndDate Get-Date -EventTypes $InboxRuleEvents
}

main