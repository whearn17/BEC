function Connect-M365 {
    Connect-AzureAd
    Connect-ExchangeOnline
}

Export-ModuleMember -Function Connect-M365