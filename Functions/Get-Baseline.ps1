function Get-OMEBaseline {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome003",

        [Parameter(Mandatory)]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter(ParameterSetName="CatalogId")]
        [ValidateNotNull()]
        [int] $CatalogId,

        [Parameter(ParameterSetName="BaselineId")]
        [ValidateNotNull()]
        [int] $BaselineId
    )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    Switch ( $PsCmdlet.ParameterSetName ) { 
        "CatalogId" { $BaselineURL = "https://$Server/api/UpdateService/Baselines" }
        "BaselineId" { $BaselineURL = "https://$Server/api/UpdateService/Baselines($($BaselineId))" }
        Default { $BaselineURL = "https://$Server/api/UpdateService/Baselines" }
    }
   
    Try {
        $Response = Invoke-WebRequest -Uri $BaselineURL -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        Write-Verbose "Status Code is $($Response.StatusCode)"

        If ($Response.StatusCode -eq 200) {
            $BaselineInfo = $Response.Content | ConvertFrom-Json
            $values = $BaselineInfo.value
            $Result = New-object System.Collections.ArrayList
            Switch ( $PsCmdlet.ParameterSetName ) {
                "CatalogId" { 
                    ForEach ($data in $values) {
                        If ($data.CatalogId -eq $CatalogId) {
                            [Void]$Result.Add($data)
                        }
                    }
                }
                "BaselineId" { 
                    [Void]$Result.Add($BaselineInfo)
                }
                Default {
                    ForEach ($data in $values) {
                        [Void]$Result.Add($data)
                    }

                }
            } 
        }
    } Catch {
        $_ | ConvertFrom-ErrorJson
    }
    Return $Result
}

Export-ModuleMember Get-OMEBaseline