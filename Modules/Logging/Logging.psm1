function Write-ConsoleLog {
    param (
        [String]$Message,
        [String]$Level
    )

    # Store the formatted date in a variable
    $currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    switch ($Level) {
        "debug" { Write-Host "$($currentDate) [DEBUG]    $Message" -ForegroundColor Gray }
        "info" { Write-Host "$($currentDate) [INFO]     $Message" -ForegroundColor White }
        "warning" { Write-Host "$($currentDate) [WARNING]  $Message" -ForegroundColor Yellow }
        "error" { Write-Host "$($currentDate) [ERROR]    $Message" -ForegroundColor Red }
        "fatal" { Write-Host "$($currentDate) [FATAL]    $Message" -ForegroundColor DarkRed }
        default { Write-Host "$($currentDate) [UNKNOWN]  $Message" -ForegroundColor Magenta }
    }
}

function Out-FileLog {
    param (
        [String]$Message,
        [String]$Level
    )

    # Construct the log message similar to Write-ScreenLog
    $currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    
    switch ($Level) {
        "debug" { $logMessage = "$currentDate [DEBUG]    $Message" }
        "info" { $logMessage = "$currentDate [INFO]     $Message" }
        "warning" { $logMessage = "$currentDate [WARNING]  $Message" }
        "error" { $logMessage = "$currentDate [ERROR]    $Message" }
        "fatal" { $logMessage = "$currentDate [FATAL]    $Message" }
        default { $logMessage = "$currentDate [UNKNOWN]  $Message" }
    }

    # Append the log message to the file
    Add-Content -Path $global:LogFile -Value $logMessage
}
