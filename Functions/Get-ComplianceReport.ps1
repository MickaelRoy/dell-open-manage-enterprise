Function Get-OMEComplianceReport {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter(Mandatory)]
        [Hashtable] $Headers,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, ParameterSetName="ServiceTag")]
        [String] $ServiceTag,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [uint64] $BaselineId,

        [Parameter()]
        [String] $Type = "application/json"
    )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    $ComplCountUrl = "https://$Server/api/UpdateService/Baselines($BaselineId)/DeviceComplianceReports?`$count=true&`$top=1" 
    $ComCountResp = Invoke-WebRequest -Uri $ComplCountUrl -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
    If ($ComCountResp.StatusCode -eq 200) {
        $ComplCountData = $ComCountResp.Content | ConvertFrom-Json
        $NumManagedCompReports = $ComplCountData.'@odata.count'
    }
    $ComplURL = "https://$Server/api/UpdateService/Baselines($BaselineId)/DeviceComplianceReports?`$skip=0&`$top=$NumManagedCompReports"
    If ($null -ne $ServiceTag) {$ComplURL = $ComplURL + "&`$filter=ServiceTag eq '$($ServiceTag)'"}
    $Response = Invoke-WebRequest -Uri $ComplURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
    
    Try {
        Write-Verbose "Status Code is $($Response.StatusCode)"
        If ($Response.StatusCode -eq 200) {
            $ComplData = $Response.Content | ConvertFrom-Json
            $Object = $ComplData.value
            $Object | Add-Member -NotePropertyName BaseLineId -NotePropertyValue $BaselineId -Force

        }
    } Catch {
        $_ | ConvertFrom-ErrorJson

    }
    Return $Object
}

Export-ModuleMember Get-OMEComplianceReport