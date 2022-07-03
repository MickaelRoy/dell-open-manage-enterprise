Function Remove-OMEGroupMember {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter()]
        [int[]] $DeviceId,

        [Parameter()]
        [int] $GroupId
    )

    Begin {

        $Server = [System.Net.Dns]::GetHostByName($Server).Hostname
        $GroupServiceURL = "https://$($Server)/api/GroupService/Actions/GroupService.RemoveMemberDevices"

    } Process {

        $Body = @{"GroupId" = $GroupId; "MemberDeviceIds" = @($DeviceId)} | ConvertTo-Json

        Try {
            $Response = Invoke-WebRequest -Uri $GroupServiceURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method Post -Body $Body
            If ($Response.StatusCode -eq 204) {
                Write-Verbose -Message "Device(s) removed successfully"
            }
        } Catch {
            $_ | ConvertFrom-ErrorJson
        }  

    }
}

Export-ModuleMember Remove-OMEGroupMember