Function Push-OMEUpdateJob {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter(Mandatory)]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, Mandatory)]
        [String] $Payload
     )
     
    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    $UpdateJobURL = "https://$Server/api/JobService/Jobs"
    $JobResp = Invoke-WebRequest -Uri $UpdateJobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $Payload
    If ($JobResp.StatusCode -eq 201) {
        Write-Verbose "Job created successfuly"
        $JobInfo = $JobResp.Content | ConvertFrom-Json
        $Object = [PsCustomObject]@{ 
            IpAddress = $Server
            Headers = $Headers
            JobId = $JobInfo.Id
        }
        Return $Object
    } Else {
        Write-Warning "Update job creation failed"
    }
}

Export-ModuleMember Push-OMEUpdateJob
