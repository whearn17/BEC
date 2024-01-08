Import-Module ..\Logging\Logging.psm1

function Copy-ToS3 {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$AccessKey,

        [Parameter(Mandatory = $true)]
        [string]$SecretKey,

        [Parameter(Mandatory = $true)]
        [string]$Region,

        [Parameter(Mandatory = $true)]
        [string]$BucketName,

        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$Key # The key is the name that the file will have in the bucket
    )

    Begin {
        # Install AWS PowerShell module if not already installed
        if (-not (Get-Module -ListAvailable -Name AWSPowerShell.NetCore)) {
            Install-Module -Name AWSPowerShell.NetCore -Force -Scope CurrentUser
        }

        Import-Module AWSPowerShell.NetCore
    }

    Process {
        try {
            # Set AWS Credentials
            Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs MyAWSProfile

            # Set the region
            Set-DefaultAWSRegion -Region $Region

            # Upload file to S3
            Write-ConsoleLog -Message "Uploading evidence to S3" -Level "info"
            Out-FileLog -Message "Uploading evidence to S3" -Level "info"
            Write-S3Object -BucketName $BucketName -File $FilePath -Key $Key -StoredCredential MyAWSProfile

            Write-ConsoleLog -Message "File uploaded successfully" -Level "info"
            Out-FileLog -Message "File uploaded successfully" -Level "info"
        }
        catch {
            Write-ConsoleLog -Message "An error occurred: $_`n`nPlease upload the zip file located at $($FilePath) manually to S3" -Level "error"
            Out-FileLog -Message "An error occurred: $_`n`nPlease upload the zip file located at $($FilePath) manually to S3" -Level "error"
        }
    }
}

Export-ModuleMember -Function Copy-ToS3