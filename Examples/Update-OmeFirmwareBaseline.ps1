Function Update-OmeFirmwareBaseline {
    Param (
        [Parameter(Mandatory)]
        [String] $ServiceTag,

        [Parameter()]
        [String] $BaselineName,

        [Parameter()]
        [ValidateSet("Preview", "RebootNow", "StageForNextReboot")]
        [String]$UpdateSchedule = "Preview",
        
        [Parameter()]
        [Switch]$ClearJobQueue,
        
        [Parameter()]
        [String] $Server = "as9000pvk0001"
    )

    $DellOmeModule = Get-Module -ListAvailable dell-open-manage-enterprise
    If ($null -eq $DellOmeModule) { Throw 'dell-open-manage-enterprise is mandatory, please install it first.' }
    Else { Import-Module dell-open-manage-enterprise }

    Switch ($Server) {

        parg0pome003 {
            $OmePwd = Get-PASPassword -UserName baremetal_svc -AppID App-OPS_IV2ACOREOS_DEV -Safe IV2ACOREOS-OPSD
            $OmeCred =  [pscredential]::new('baremetal_svc',(ConvertTo-SecureString $OmePwd -AsPlainText -Force))

        }
        as9000pvk0001 {
            $OmePwd = Get-PASPassword -Name MADRID_[svc][ome] -AppID App-OPS_IV2AVIRTUALIZATI_PRD -Safe IV2AVIRTUALIZATIONP-OPSP
            $OmeCred =  [pscredential]::new('MADRID',(ConvertTo-SecureString $OmePwd -AsPlainText -Force))
        }
        Default {
            $OmePwd = Get-PASPassword -UserName baremetal_svc -AppID App-OPS_IV2ACOREOS_DEV -Safe IV2ACOREOS-OPSD
            $OmeCred =  [pscredential]::new('baremetal_svc',(ConvertTo-SecureString $OmePwd -AsPlainText -Force))
        }
    }
    Try {
        $headers = New-OMESession -Credentials $OmeCred -Server $Server
    } Catch {
        Throw $_
    }

    $Device = Get-OMEDevice -Server $Server -Headers $Headers -ServiceTag $ServiceTag

    $Baseline = Get-OMEDeviceBaseline -Server $Server -Headers $Headers -DeviceId $Device.Id
    If ($null -ne $BaselineName) {
        $Baseline = $Baseline | Where-Object Name -Match $BaselineName
    }

    If (@($Baseline).count -eq 0) {
        Throw "No baseline found with the specified parameters."
    } ElseIf (@($Baseline).count -ge 2) {
        Throw "too many baselines found with the specified parameters. $($Baseline.Name -join ", ")"
    }


    $ComplianceReport = Get-OMEComplianceReport -Server $Server -Headers $Headers -BaselineId $Baseline.Id -ServiceTag $ServiceTag
    If ($UpdateSchedule -eq "Preview") { # Only show report, do not perform any updates
        Return $ComplianceReport
    }

    If ($null -ne $Device) {
        If ($ComplianceReport.FirmwareStatus -eq "Non-Compliant") {

            $Payload = New-OMEUpdateJob -Server $Server -Headers $Headers -ComplianceReport $ComplianceReport -ClearJobQueue:$($ClearJobQueue.IsPresent) -UpdateSchedule $UpdateSchedule

            $Job = Push-OMEUpdateJob -Server $Server -Headers $Headers -Payload $Payload

            $Status = Wait-OMEJob -JobId $Job.JobId -Server $Server -Headers $Headers

        } ElseIf ($ComplianceReport.FirmwareStatus -eq "Compliant") {
            Write-Verbose -Message "This Server is firmware compliant."
            $Status = 'Compliant'
        } ElseIf ($ComplianceReport.FirmwareStatus -eq "Unknown") {
            Write-Verbose -Message "This baseline looks not applicable."
            $Status = 'Non-Applicable'
        } Else {
            Write-Verbose -Message "This compliance status is not managed yet."
            $Status = 'Unknown-Error'
        }
    } Else {
        $Status = 'NotInOME'
    }

    Remove-OMESession -Headers $headers -Server $Server
    
    Return $Status

}

Export-ModuleMember Update-OmeFirmwareBaseline