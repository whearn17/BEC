function Get-AuditLogs {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$EventTypes,

        [Parameter(Mandatory = $true)]
        [DateTime]$SearchStartDate,

        [Parameter(Mandatory = $true)]
        [DateTime]$SearchEndDate,

        [Parameter(Mandatory = $true)]
        [string]$AuditLogOutputPath
    )

    $maximumRetryAttempts = 3
    $processingIntervalDays = 1 # Adjust as needed
    $currentStartDate = $SearchStartDate

    while ($currentStartDate -lt $SearchEndDate) {
        $currentEndDate = $currentStartDate.AddDays($processingIntervalDays)
        if ($currentEndDate -gt $SearchEndDate) { $currentEndDate = $SearchEndDate }

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
                Write-Host "Error encountered: $($_.Exception.Message). Retrying..." -ForegroundColor Yellow
                Start-Sleep -Seconds 10
                $currentRetryCount++
            }
        }

        if ($currentRetryCount -eq $maximumRetryAttempts) {
            Write-Host "Error after $maximumRetryAttempts retries. Continuing to next batch..." -ForegroundColor Red
        }

        $currentStartDate = $currentEndDate
    }
}

Export-ModuleMember -Function Get-AuthenticationLogs