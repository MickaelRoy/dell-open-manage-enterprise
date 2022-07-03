Function Add-DevicesToGroup {
    [CmdletBinding()]
    param(
        [Parameter()]
        [String] $Server = "parg0pome001",

        [Parameter(Mandatory)]
        [pscredential] $Credentials,

        [Parameter()]
        [String] $GroupName = "BARE-METAL",

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName)]
        [alias("Id")]
        [int[]] $DeviceId,

        [Parameter()]
        [Switch] $Wait
    )

    Begin {

        Import-Module .\OMEnt -Force
        $Headers = New-OMESession -Server $Server -Credentials $Credentials

        $Group = Get-OMEGroup -Server $Server -Headers $Headers -Name $GroupName

    } Process {

        Add-OMEGroupMember -Headers $Headers -DeviceId $DeviceId -GroupId $Group.id


    } End {


    }


}

