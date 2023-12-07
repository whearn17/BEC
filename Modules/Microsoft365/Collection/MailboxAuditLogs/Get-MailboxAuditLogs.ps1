function Get-IncrementalMailboxAuditLogs {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName,

        [Parameter(Mandatory = $true)]
        [datetime]$StartDate,

        [Parameter(Mandatory = $true)]
        [datetime]$EndDate
    )

    # Initialize an array to hold the results
    [array]$Results = @()

    # Set the initial start date for the search
    [datetime]$RangeStart = $StartDate

    do {
        # Determine the end date of the current 5-day interval
        [datetime] $RangeEnd = $RangeStart.AddDays(5)
        if ($RangeEnd -gt $EndDate) {
            $RangeEnd = $EndDate
        }

        # Perform the search for the current 5-day range
        $CurrentResults = Search-MailboxAuditLog -StartDate $RangeStart -EndDate $RangeEnd -identity $UserPrincipalName -ShowDetails -ResultSize 250000
        # Append the results from the current search to the overall results
        $Results += $CurrentResults

        # Move to the next 5-day interval
        $RangeStart = $RangeEnd.AddDays(1)
    }
    # Continue the loop until the entire date range is covered
    while ($RangeStart -le $EndDate)

    # Return all collected audit log entries
    return $Results
}