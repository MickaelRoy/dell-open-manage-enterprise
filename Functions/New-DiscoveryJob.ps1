Function New-OMEDiscoveryJob {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter(Mandatory)]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, Mandatory)]
        [String[]] $Ipaddress,

        [Parameter(Mandatory)]
        [pscredential] $Credentials

    )

    Begin {

        $UserName = $Credentials.username
        $Password = $Credentials.GetNetworkCredential().password

        $ConnectionProfile = [ordered]@{
            "profileName" = ""
            "profileDescription" = ""
            "type" = "DISCOVERY"
            "credentials" = @(
                [ordered]@{
                    "type" = "WSMAN"
                    "authType" = "Basic"
                    "modified" = $false
                    "credentials" = [ordered]@{
                        "username" = $UserName
                        "password" = $Password
                        "port" = 443
                        "retries" = 3
                        "timeout" = 60
                    }
                }
            )
        } | ConvertTo-Json -Depth 6
        $DiscoveryConfigTargets = New-Object System.Collections.ArrayList


    } Process {
        $Ipaddress | Foreach {

            $jsonContent = [PSCustomObject]@{
                'NetworkAddressDetail' = [string]$_
            }
            Write-Verbose -Message "adding $jsonContent in target list"
            [void]$DiscoveryConfigTargets.Add($jsonContent)

        }

    } End {

        $Payload = [ordered]@{
            "DiscoveryConfigGroupName" = "Server Discovery"
            "DiscoveryConfigModels" = @(
                @{
                    "ConnectionProfile" = $ConnectionProfile
                    'DiscoveryConfigTargets' = $DiscoveryConfigTargets
                    "DeviceType" = @(
                        1000
                    )
                }
            )
            "Schedule" = [ordered]@{
                "RunNow" = $true
                "Cron" = "startnow"
            }
        }

        Return $Payload | ConvertTo-Json -Depth 6

    }
}

Export-ModuleMember New-OMEDiscoveryJob