Import-Module ..\..\..\Logging\Logging.psm1

function Get-AuditLogs {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$EventTypes,

        [Parameter(Mandatory = $true)]
        [DateTime]$SearchStartDate,

        [Parameter(Mandatory = $true)]
        [string]$AuditLogOutputPath,

        [Parameter(Mandatory = $true)]
        [string]$ErrorLogPath
    )

    $maximumRetryAttempts = 3
    $processingIntervalDays = 1 # Adjust as needed
    $currentStartDate = $SearchStartDate

    while ($currentStartDate -lt (Get-Date)) {
        $currentEndDate = $currentStartDate.AddDays($processingIntervalDays)
        if ($currentEndDate -gt (Get-Date)) { $currentEndDate = (Get-Date) }

        $sessionID = [Guid]::NewGuid().ToString() + "_" + "ExtractLogs" + (Get-Date).ToString("yyyyMMddHHmmssfff")
        $currentRetryCount = 0

        while ($currentRetryCount -lt $maximumRetryAttempts) {
            try {
                $auditResults = Search-UnifiedAuditLog -StartDate $currentStartDate -EndDate $currentEndDate -SessionId $sessionID -SessionCommand ReturnLargeSet -ResultSize 5000 -Operations $EventTypes

                if ($auditResults.Count -gt 0) {
                    $auditResults | Export-Csv -Path "$($AuditLogOutputPath)\AuditLogs.csv" -Append -NoTypeInformation -Encoding UTF8
                }

                break
            }
            catch {
                Write-ConsoleLog -Message "Error encountered: $($_.Exception.Message). Retrying..." -Level "warning"
                Out-FileLog -Message "Error encountered: $($_.Exception.Message). Retrying..." -Level "warning" -LogPath $ErrorLogPath
                Start-Sleep -Seconds 10
                $currentRetryCount++
            }
        }

        if ($currentRetryCount -eq $maximumRetryAttempts) {
            Write-ConsoleLog "Error after $maximumRetryAttempts retries. Continuing to next batch..." -Level "warning"
            Out-FileLog "Error after $maximumRetryAttempts retries. Continuing to next batch..." -Level "warning" -LogPath $ErrorLogPath
        }

        $currentStartDate = $currentEndDate
    }

    Write-ConsoleLog -Message "Finished searching audit log for $($EventTypes)" -Level "info"
    Out-FileLog -Message "Finished searching audit log for $($EventTypes)" -Level "info" -LogPath $ErrorLogPath
}

Export-ModuleMember -Function Get-AuditLogs