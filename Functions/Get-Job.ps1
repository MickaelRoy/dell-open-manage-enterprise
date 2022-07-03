Function Get-OMEJob {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName)]
        [String] $Server = "parg0pome001",

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, Mandatory)]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName)]
        [uint64] $JobId
     )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    If ( $JobId ) { $UpdateJobURL = "https://$Server/api/JobService/Jobs($($JobId))" }
    Else { $UpdateJobURL = "https://$Server/api/JobService/Jobs" }

    $JobResp = Invoke-WebRequest -Uri $UpdateJobURL -UseBasicParsing -Headers $Headers -ContentType $Type
    $JobInfo = $JobResp.Content | ConvertFrom-Json


    If ( $JobId ) { Return $JobInfo }
    Else { Return $JobInfo.value }
    


}

Export-ModuleMember Get-OMEJob
