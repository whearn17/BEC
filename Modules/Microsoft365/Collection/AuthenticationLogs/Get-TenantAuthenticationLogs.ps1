param (
    # Start date and time for audit log search
    [Parameter(Mandatory = $true)]
    [DateTime]$searchStartDate,

    # End date and time for audit log search
    [Parameter(Mandatory = $true)]
    [DateTime]$searchEndDate,

    # Default output path for saving the audit logs
    [Parameter(Mandatory = $true)]
    [string]$auditLogOutputPath = "C:\temp\"
)

# Specifies the type of operation to search in audit logs
$auditOperationType = "UserLoggedIn"

# Generate a unique session ID for each search
$auditSessionID = New-AuditSessionID

# Sets the maximum number of records to retrieve in a single search
$maximumResultSize = 5000

# Generates a new session ID for audit log search
function New-AuditSessionID() {
    return [Guid]::NewGuid().ToString() + "_" + "ExtractLogs" + (Get-Date).ToString("yyyyMMddHHmmssfff")
}

# Searches the Unified Audit Log based on provided parameters
function Search-AuditLog($startDate, $endDate, $sessionID, $resultSize, $outputPath, $operationType) {
    $maximumRetryAttempts = 3
    $currentRetryCount = 0

    while ($currentRetryCount -lt $maximumRetryAttempts) {
        try {
            # Perform the audit log search
            $auditResults = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -SessionId $sessionID -SessionCommand ReturnLargeSet -ResultSize $resultSize -RecordType $operationType

            # Export results to CSV if any records are found
            if ($auditResults.Count -gt 0) {
                $auditResults | Export-Csv -Path "$($outputPath)\AuditLogs.csv" -Append -NoTypeInformation -Encoding UTF8
            }

            return $auditResults.Count -gt 0
        }
        catch {
            Write-Host "Error encountered: $($_.Exception.Message). Retrying..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
            $currentRetryCount++
        }
    }
    Write-Host "Error after $maximumRetryAttempts retries. Continuing to next batch..." -ForegroundColor Red
}

# Retrieves all audit records within the specified date range
function Get-AllAuditRecords($startDate, $endDate, $operationType, $outputPath) {
    $currentStartDate = $startDate
    $processingIntervalDays = 1 # Process one day at a time, adjust as needed

    while ($currentStartDate -lt $endDate) {
        $currentEndDate = $currentStartDate.AddDays($processingIntervalDays)
        if ($currentEndDate -gt $endDate) { $currentEndDate = $endDate }

        # Search for audit logs within the specified interval
        $hasResults = Search-AuditLog $currentStartDate $currentEndDate $sessionID $resultSize $outputPath $operationType

        if (!$hasResults) { break }

        $currentStartDate = $currentEndDate
    }
}

# Start the audit log retrieval process
Get-AllAuditRecords $searchStartDate $searchEndDate $auditOperationType $auditLogOutputPath
