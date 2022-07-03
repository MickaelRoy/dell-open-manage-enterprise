Function Add-OMEGroupMember {

    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName)]
        [alias("Id")]
        [int[]] $DeviceId,

        [Parameter()]
        [int] $GroupId
    )

    Begin {

        $Server = [System.Net.Dns]::GetHostByName($Server).Hostname
        $GroupServiceURL = "https://$Server/api/GroupService/Actions/GroupService.AddMemberDevices"

    } Process {

        $Body = @{"GroupId" = $GroupId; "MemberDeviceIds" = @($DeviceId)} | ConvertTo-Json

        Try {
            $Response = Invoke-WebRequest -Uri $GroupServiceURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $Body
            If ($Response.StatusCode -eq 204) {
                Write-Verbose -Message "Device(s) added successfully"
            }
        } Catch {
            Write-Warning -Message "Error on $DeviceId"
            $_ | ConvertFrom-ErrorJson
        }
    }

}

Export-ModuleMember Add-OMEGroupMember