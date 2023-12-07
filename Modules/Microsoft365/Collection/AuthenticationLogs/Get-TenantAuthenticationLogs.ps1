param (
    [Parameter(Mandatory = $true)]
    [DateTime]$start,

    [Parameter(Mandatory = $true)]
    [DateTime]$end,

    [Parameter(Mandatory = $true)]
    [string]$outputPath = "C:\temp\"
)

$operationType = "UserLoggedIn"
$sessionID = New-SessionID
$resultSize = 5000

function New-SessionID() {
    return [Guid]::NewGuid().ToString() + "_" + "ExtractLogs" + (Get-Date).ToString("yyyyMMddHHmmssfff")
}

function Search-AuditLog($start, $end, $sessionID, $resultSize, $outputPath, $operationType) {
    $maxRetries = 3
    $retryCount = 0

    while ($retryCount -lt $maxRetries) {
        try {
            $results = Search-UnifiedAuditLog -StartDate $start -EndDate $end -SessionId $sessionID -SessionCommand ReturnLargeSet -ResultSize $resultSize -RecordType $operationType

            if ($results.Count -gt 0) {
                $results | Export-Csv -Path "$($outputPath)\AuditLogs.csv" -Append -NoTypeInformation -Encoding UTF8
            }

            return $results.Count -gt 0
        }
        catch {
            Write-Host "Error encountered: $($_.Exception.Message). Retrying..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
            $retryCount++
        }
    }
    Write-Host "Error after $maxRetries retries. Continuing to next batch..." -ForegroundColor Red
}

function Get-AllAuditRecords($start, $end, $operationType, $outputPath) {
    $currentStart = $start
    $intervalDays = 1 # Process one day at a time, adjust as needed

    while ($currentStart -lt $end) {
        $currentEnd = $currentStart.AddDays($intervalDays)
        if ($currentEnd -gt $end) { $currentEnd = $end }

        $hasResults = Search-AuditLog $currentStart $currentEnd $sessionID $resultSize $outputPath $operationType

        if (!$hasResults) { break }

        $currentStart = $currentEnd
    }
}


Get-AllAuditRecords $start $end $operationType $outputPath