Function Get-OMEGroup {
    [CmdletBinding(DefaultParametersetname="Default")]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter(ParameterSetName="Name")]
        [ValidateNotNull()]
        [String] $Name,

        [Parameter(ParameterSetName="GroupId")]
        [ValidateNotNull()]
        [String] $GroupId
    )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    <#$GroupCountUrl = "https://$($IpAddress)/api/GroupService/Groups?`$count=true&`$top=0" 
    $GrpCountResp = Invoke-WebRequest -Uri $GroupCountUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
    if ($GrpCountResp.StatusCode -eq 200) {
        $GroupCountData = $GrpCountResp.Content | ConvertFrom-Json
        $NumManagedGroups = $GroupCountData.'@odata.count'
    }#>
    $NumManagedGroups = 10000

    Switch ($PsCmdlet.ParameterSetName) {
        "Name" {
            Write-Verbose "Get groups corresponding to $Name..."
            $GroupServiceURL = "https://$Server/api/GroupService/Groups?`$skip=0&`$top=$($NumManagedGroups)&`$filter=Name eq '$($Name)'"
        }
        "GroupId" {
            Write-Verbose "Get groups corresponding to $GroupId..."
            $GroupServiceURL = "https://$Server/api/GroupService/Groups($($GroupId))"
        }
        default {
            If ($NumManagedGroups -gt 0) {
                Write-Verbose "Get all groups..."
                $GroupServiceURL = "https://$Server/api/GroupService/Groups?`$skip=0&`$top=$($NumManagedGroups)"
            }
        }
    } 

    Try {
        $Response = Invoke-WebRequest -Uri $GroupServiceURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
        If ($Response.StatusCode -eq 200) {
            Write-Verbose "Building Collection..."
            $GroupList = New-Object System.Collections.ArrayList
            $GrpResp = $Response.Content | ConvertFrom-Json
            Switch ($PsCmdlet.ParameterSetName) { 
                "Name" { [Void]$GroupList.Add($GrpResp.value) }
                "GroupId" { [Void]$GroupList.Add($GrpResp) }
                default { $GrpResp.value | Sort-Object Id | ForEach-Object { [Void]$GroupList.Add($_) } }
            }
        } Else {
            Write-Warning "Unable to fetch Group info...skipping"
        }

    } Catch {
        $_ | ConvertFrom-ErrorJson
    }
    Return $GroupList

}
 
Export-ModuleMember Get-OMEGroup