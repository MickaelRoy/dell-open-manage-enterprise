Function Remove-OMEGroup {
    [CmdletBinding(DefaultParametersetname="Default")]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [ValidateNotNull()]
        [String] $GroupName
    )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    Try {
    
        $Group = Get-OMEGroup -Headers $Headers -Name $GroupName -Server $Server

    } Catch {

        Throw "Unable to find group `'$GroupName`'"

    }

    $GrpPayload = @{"GroupIds" = @($Group.Id)} | ConvertTo-Json

    $GrpDeleteUrl = "https://$Server/api/GroupService/Actions/GroupService.DeleteGroup"

    Try {

        $CreateResp = Invoke-WebRequest -Uri $GrpDeleteUrl -UseBasicParsing -Method Post -Headers $Headers -ContentType $Type -Body $GrpPayload
        If ($CreateResp.StatusCode -eq 200) { Get-OMEGroup -Headers $Headers -Name $Name }

    } Catch {

        $_ | ConvertFrom-ErrorJson

    }

}

Export-ModuleMember Remove-OMEGroup