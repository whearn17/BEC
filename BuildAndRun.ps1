$OutputBinary = ".\Collector.exe"

if (Test-Path $OutputBinary) {
    Remove-Item $OutputBinary
}

ps2exe -inputFile .\Collect.ps1 -outputFile $OutputBinary -x64 -credentialGUI -company "Surefire Cyber Inc." -title "M365 Collector"

.\Collector.exe