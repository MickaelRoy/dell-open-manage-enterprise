Function Get-OMEGroupMember {

    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter()]
        [int] $GroupId
    )

        $Server = [System.Net.Dns]::GetHostByName($Server).Hostname
        $GroupCountUrl = "https://$Server/api/GroupService/Groups($GroupId)/Devices?`$top=1"

        $GrpCountResp = Invoke-WebRequest -Uri $GroupCountUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        If ($GrpCountResp.StatusCode -eq 200) {
            $GroupCountData = $GrpCountResp.Content | ConvertFrom-Json
            $NumManagedGroups = $GroupCountData.'@odata.count'
        }

        $GroupServiceURL = "https://$Server/api/GroupService/Groups($GroupId)/Devices?`$top=$($NumManagedGroups)"

        Try {
            $Response = Invoke-WebRequest -Uri $GroupServiceURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
            If ($Response.StatusCode -eq 200) {
                Write-Verbose -Message "Group members grabed successfully"
            }
        } Catch {
            Write-Warning -Message "Error on $DeviceId"
            $_ | ConvertFrom-ErrorJson
        }


        $json = ($Response.Content | ConvertFrom-Json).value
        Return $json

}

Export-ModuleMember Get-OMEGroupMember