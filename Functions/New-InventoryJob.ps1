Function New-OMEInventoryJob {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [System.Net.IPAddress] $IpAddress,

        [Parameter(Mandatory)]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter()]
        [String] $Description = $null,

        [Parameter(Mandatory)]
        [uint64[]] $DeviceId
    )


    $TargetTypeList = New-Object System.Collections.ArrayList
    
    
    Foreach ( $Id in $DeviceId ) {
        $TargetHash = @{}
        Write-Verbose "Getting infos of $Id" 
        $DeviceInfos = Get-OMEDevice -IpAddress $IpAddress -Headers $Headers -DeviceId $Id
        $TargetList = New-Object System.Collections.ArrayList

        # Build Targets
            $TargetHash.Data = $null
            $TargetHash.Id = $DeviceInfos.Id

        ## Buid TargetType child
            $TargetTypeHash = @{ Id = $DeviceInfos.Type }
            $TargetHash.TargetType = $TargetTypeHash
        
        ## Feed the list 
            [Void]$TargetTypeList.Add($TargetHash)


    }

    $Payload = New-Object hashtable
    $Payload.JobType = [PsCustomObject]@{Id = 8; Name = "Inventory_Task"}
    $Payload.Params = @(
            [PsCustomObject]@{ Key = "complianceReportId"; Value = [String]60 }
            [PsCustomObject]@{ Key = "repositoryId"; Value = [String]44 }
            [PsCustomObject]@{ Key = "catalogId"; Value = [String]54}
            [PsCustomObject]@{ Key = "name"; Value = "PostComplianceTask" }
            [PsCustomObject]@{ Key = "downgradeEnabled"; Value = "true" }
            [PsCustomObject]@{ Key = "CALLED_FROM_FW"; Value = "false" }
            [PsCustomObject]@{ Key = "description"; Value = "Compliance Task for Post Firmware update task" }
    )
    $Payload.Targets = [Array]$TargetTypeList

    $Payload.JobName = "Inventory Task Device"
    $Payload.JobDescription = "Inventory Task Device"
    $Payload.Schedule = "startnow"
    $Payload.State = "Enabled"
    

    
    
    Return $Payload | ConvertTo-Json -Depth 6
}

Export-ModuleMember New-OMEInventoryJob