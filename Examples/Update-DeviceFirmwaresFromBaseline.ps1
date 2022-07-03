Function Update-DeviceFirmwaresFromBaseline {
    [CmdletBinding()]
    param(
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter(Mandatory)]
        [pscredential] $Credentials,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, Mandatory)]
        [String] $ServiceTag,

        [Parameter()]
        [Switch] $Wait
    )

    Begin {

        Import-Module .\OMEnt -Force
        $Headers = New-OMESession -Server $Server -Credentials $Credentials

        $ComplianceReportList = New-Object System.Collections.Generic.List[Object]


    } Process {

        $Device = Get-OMEDevice -Server $Server -Headers $Headers -ServiceTag $ServiceTag

        $Baseline = Get-OMEDeviceBaseline -Server $Server -Headers $Headers -DeviceId $Device.Id

        $ComplianceReport = Get-OMEComplianceReport -Server $Server -Headers $Headers -BaselineId $Baseline.Id
        $Item = $ComplianceReport | Where-Object ServiceTag -eq $ServiceTag

        $ComplianceReportList.Add($Item)


    } End {

        $Payload = New-OMEUpdateJob -Server $Server -Headers $Headers -ComplianceReport $ComplianceReportList

        $Job = Push-OMEUpdateJob -Server $Server -Headers $Headers -Payload $Payload

        $Job | Write-Output


    }
}