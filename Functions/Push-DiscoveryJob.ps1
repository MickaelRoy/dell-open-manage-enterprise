function Push-OMEDiscoveryJob {
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

    $DiscoveryJobURL = "https://$Server/api/DiscoveryConfigService/DiscoveryConfigGroups"
    $JobResp = Invoke-WebRequest -Uri $DiscoveryJobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $Payload
    If ($JobResp.StatusCode -eq 201) {
        Write-Verbose "Job created successfuly"
        $JobInfo = $JobResp.Content | ConvertFrom-Json
        $Object = [PsCustomObject]@{ 
            IpAddress = $Server
            Headers = $Headers
            JobId = $JobInfo.DiscoveryConfigTaskParam.TaskId
        }
        Return $Object
    } Else {
        Write-Warning "Update job creation failed"
    }

}


Export-ModuleMember Push-OMEDiscoveryJob