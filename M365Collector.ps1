.\Modules\ReloadModules.ps1
Import-Module .\Modules\Logging\Logging.psm1
Import-Module .\Modules\Microsoft365\Authentication\M365Auth.psm1
Import-Module .\Modules\Microsoft365\Collection\MailboxAuditLogs\MailboxAuditLogs.psm1
Import-Module .\Modules\Microsoft365\Collection\AuditLogs\AuditLogs.psm1

$LogFile = ".\Logs\archimedes$(Get-Date -Format "yyyy-MM-dd").log"
$InboxRulesLogOutput = ".\Output\Logs\InboxRules\"
$AuthenticationLogOutput = ".\Output\Logs\Authentication"

function New-RequiredDirectories {
    [string[]] $RequiredDirectories = @(".\Logs", ".\Output", ".\Output\Logs", ".\Output\Logs\InboxRules\", ".\Output\Logs\Authentication")

    foreach ($Directory in $RequiredDirectories) {
        if (-not (Test-Path $Directory)) {
            New-Item -Path $Directory -ItemType "directory"
        }
    }
}

function main {

    Write-ConsoleLog -Message "Collector started" -Level "info"
    Out-FileLog -Message "Collector started" -Level "info" -LogPath $LogFile

    Write-ConsoleLog -Message "Creating output directories" -Level "info"
    Out-FileLog -Message "Creating output directories" -Level "info"
    New-RequiredDirectories

    Write-ConsoleLog -Message "Connecting to M365 Endpoints" -Level "info"
    Out-FileLog -Message "Connecting to M365 Endpoints" -Level "info" -LogPath $LogFile
    Connect-M365

    [string]$TenantDomainName = (Get-AcceptedDomain | Where-Object { $_.Default -eq $true }).DomainName

    Write-ConsoleLog -Message "Gathering user principal name list from tenant" -Level "info"
    Out-FileLog -Message "Gathering user principal name list from tenant" -Level "info" -LogPath $LogFile
    [string[]]$AllUserPrincipalNames = Get-Mailbox -ResultSize Unlimited | Select-Object UserPrincipalName


    # Exchange Mailbox Audit Logs

    Write-ConsoleLog -Message "Gathering user mailbox audit logs" -Level "info"
    Out-FileLog -Message "Gathering user mailbox audit logs" -Level "info" -LogPath $LogFile
    Get-MailboxAuditLogs -UserPrincipalNames $AllUserPrincipalNames -DomainName $TenantDomainName -StartDate (Get-Date).AddDays(-90) -EndDate Get-Date

    # Unified Audit Logs

    $AuthenticationEvents = @("UserLoggedIn")
    $InboxRuleEvents = @("New-InboxRule", "Set-InboxRule", "Remove-InboxRule")

    Write-ConsoleLog -Message "Gathering user authentication logs" -Level "info"
    Out-FileLog -Message "Gathering user authentication logs" -Level "info" -LogPath $LogFile
    Get-AuditLogs -SearchStartDate (Get-Date).AddDays(-90) -EndDate Get-Date -EventTypes $AuthenticationEvents -AuditLogOutputPath $AuthenticationLogOutput

    Write-ConsoleLog -Message "Gathering user inbox rule logs" -Level "info"
    Out-FileLog -Message "Gathering user inbox rule logs" -Level "info" -LogPath $LogFile
    Get-AuditLogs -SearchStartDate (Get-Date).AddDays(-90) -EndDate Get-Date -EventTypes $InboxRuleEvents -AuditLogOutputPath $InboxRulesLogOutput
}

main