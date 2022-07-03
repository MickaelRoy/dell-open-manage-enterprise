Function Get-OMEDevice {
    [CmdletBinding(DefaultParametersetname="Default")]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, ParameterSetName="ServiceTag")]
        [String] $ServiceTag,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, ParameterSetName="DeviceId")]
        [uint64] $DeviceId
    )

    Begin {

        $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

        $DeviceCountUrl = "https://$Server/api/DeviceService/Devices?`$count=true&`$top=1" 
        $DevCountResp = Invoke-WebRequest -Uri $DeviceCountUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        If ($DevCountResp.StatusCode -eq 200) {
            $DeviceCountData = $DevCountResp.Content | ConvertFrom-Json
            $NumManagedDevices = $DeviceCountData.'@odata.count'
        }

    } Process {

       Switch ( $PsCmdlet.ParameterSetName ) { 
            "ServiceTag" {
                Write-Verbose "Get devices corresponding to $ServiceTag..."
                $DeviceServiceURL = "https://$Server/api/DeviceService/Devices?`$skip=0&`$top=$($NumManagedDevices)&`$filter=Identifier eq '$($ServiceTag)'"
            }
            "DeviceId" {
                Write-Verbose "Get devices corresponding to Id $DeviceId..."
                $DeviceServiceURL = "https://$Server/api/DeviceService/Devices($($DeviceId))"
            }
            Default {
                Write-Verbose "Get all devices..."
                $DeviceServiceURL = "https://$Server/api/DeviceService/Devices?`$skip=0&`$top=$($NumManagedDevices)&`$orderby=DeviceName asc"
            }
        } 

        Try {
            
            $Response = Invoke-WebRequest -Uri $DeviceServiceURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
            If ( $Response.StatusCode -eq 200 ) {
                $DevResp = $Response.Content | ConvertFrom-Json
                Switch ( $PsCmdlet.ParameterSetName ) { 
                    "ServiceTag" { $DevResp.value }
                    "DeviceId" { $DevResp }
                    Default { $DevResp.value }
                }     
            } Else {
                Write-Warning "Unable to fetch device info...skipping"
            }
        } Catch {
            $_ | ConvertFrom-ErrorJson
        }


    }
    End {
    
    }

}
 
Export-ModuleMember Get-OMEDevice