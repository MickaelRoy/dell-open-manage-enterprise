Function Get-OMEDeviceBaseline {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter(Mandatory)]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [ValidateNotNull()]
        [int] $DeviceId
    )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    $GetBaselineUrl = "https://$Server/api/UpdateService/Actions/UpdateService.GetBaselinesForDevices"

    $body = @{ DeviceIds = @($DeviceId) } | ConvertTo-Json -Depth 6 

    Try {
        $Response = Invoke-WebRequest -Uri $GetBaselineUrl -UseBasicParsing -Headers $Headers -ContentType $Type -Method Post -Body $body
            If ( $Response.StatusCode -eq 200 ) {
                $Response.Content | ConvertFrom-Json
            } Else {
                Write-Error -Message "HTTP Status Code returned not expected"
            }
    } Catch {
        $_ | ConvertFrom-ErrorJson
    }
}


Export-ModuleMember Get-OMEDeviceBaseline