Function New-OMEUpdateJob {
    [CmdletBinding()]
    Param (
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter(Mandatory)]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter()]
        [String] $Description = $null,

        [Parameter(Mandatory)]
        $ComplianceReport,

        [Parameter()]
        [ValidateSet("PowerCycle", "Graceful", "GracefulForced")]
        $rebootType = "PowerCycle",

        [Parameter()]
        [ValidateSet("RebootNow", "StageForNextReboot")]
        [String]$UpdateSchedule = "StageForNextReboot",

        [Parameter()]
        [Switch]$ResetiDRAC,

        [Parameter()]
        [Switch]$ClearJobQueue
    
    )

# Declare reboot value.
enum rebootType
{
   PowerCycle = 1
   Graceful = 2
   GracefulForced = 3
}

$intRebootType = [rebootType]::$rebootType.value__

# Declare Stage value
    $StageUpdate = $true
    $Schedule = "startNow"

    If ($UpdateSchedule -eq "RebootNow") {
        $StageUpdate = $false
    } Elseif ($UpdateSchedule -eq "StageForNextReboot") {
        $StageUpdate = $true
    }

# Declare server value (OME)
    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname


    $TargetTypeList = New-Object System.Collections.ArrayList
    
    Foreach ( $Report in $ComplianceReport) {
        $TargetList = New-Object System.Collections.ArrayList
        $SourcesArray = New-Object System.Collections.ArrayList
        $TargetHash = @{}


        # Build Targets
            $ComponentList = $Report.ComponentComplianceReports
            ForEach ( $Component in $ComponentList ) {
                If ( $Component.UpdateAction -match "GRADE" ) {
                        [Void]$SourcesArray.Add($Component.SourceName)
                }
            }
            $TargetHash.Data = $SourcesArray.ToArray([string]) -join ";"
            $TargetHash.Id = $Report.DeviceId

        ## Buid TargetType child
            $TargetTypeHash = @{}
            $TargetTypeHash.'Id' = $Report.DeviceTypeId
            #$TargetTypeHash.'Name' = "DEVICE"
            $TargetHash.TargetType = $TargetTypeHash
        
        ## Feed the list 
            [Void]$TargetTypeList.Add($TargetHash)
    }


    $Baseline = Get-OMEBaseline -Server $Server -Headers $Headers -Type $Type -BaselineId ($ComplianceReport.BaselineId)[0]

    $Payload = New-Object hashtable
    $Payload.JobName = "Firmware-Update"
    $Payload.JobDescription = "Firmware Update Job"
    $Payload.Schedule = "startnow"
    $Payload.State = "Enabled"
    $Payload.JobType = [PsCustomObject]@{Id = 5; Name = "Update_Task"}
    $Payload.Params = @(
            [PsCustomObject]@{ Key = "complianceReportId"; Value = [String]$Baseline.Id }
            [PsCustomObject]@{ Key = "repositoryId"; Value = [String]$Baseline.RepositoryId }
            [PsCustomObject]@{ Key = "catalogId"; Value = [String]$Baseline.CatalogId }
            [PsCustomObject]@{ Key = "operationName"; Value = "INSTALL_FIRMWARE" }
            [PsCustomObject]@{ Key = "complianceUpdate"; Value = "true" }
            [PsCustomObject]@{ Key = "signVerify"; Value = "true" }
            [PsCustomObject]@{ Key = "clearJobQueue"; Value = $ClearJobQueue.ToString() }
            [PsCustomObject]@{ Key = "firmwareReset"; Value = $ResetiDRAC.ToString() }
            [PsCustomObject]@{ Key = "stagingValue"; Value = $StageUpdate.ToString() }
            [PsCustomObject]@{ Key = "rebootType"; Value = "$intRebootType" }
    )
    $Payload.Targets = [Array]$TargetTypeList 
    
    Return $Payload | ConvertTo-Json -Depth 6
}

Export-ModuleMember New-OMEUpdateJob