Function New-OMEGroup {
    [CmdletBinding(DefaultParametersetname="Default")]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [ValidateNotNull()]
        [String] $Name,

        [Parameter()]
        [String] $Description,

        [Parameter()]
        [String] $ParentName = "S2D Nodes"
    )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    Try {

        $S2DGroup = Get-OMEGroup -Headers $Headers -Name $ParentName -Server $Server

    } Catch {

        Throw "Unable to find group `'$ParentName`'"

    }

    $GrpInfo = @{
        "Name" = $Name
        "Description" = $Description
        "MembershipTypeId" = 12
        "ParentId" = [uint32]$S2DGroup[0].Id
    }
    $GrpPayload = @{"GroupModel" = $GrpInfo} | ConvertTo-Json

    $GrpCreateUrl = "https://$Server/api/GroupService/Actions/GroupService.CreateGroup"

    Try {

        $CreateResp = Invoke-WebRequest -Uri $GrpCreateUrl -UseBasicParsing -Method Post -Headers $Headers -ContentType $Type -Body $GrpPayload
        If ($CreateResp.StatusCode -eq 200) { Get-OMEGroup -Headers $Headers -Server $Server -Name $Name }

    } Catch {

        $_ | ConvertFrom-ErrorJson

    }

}

Export-ModuleMember New-OMEGroup