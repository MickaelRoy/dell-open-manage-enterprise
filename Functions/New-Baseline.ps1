Function New-OMEBaseline {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [System.Net.IPAddress] $IpAddress,

        [Parameter()]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter()]
        [String] $Name = "Baseline_$([datetime]::Now.ToString("yyyyMMdd"))",

        [Parameter()]
        [String] $Description = $null,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateNotNull()]
        [uint64] $CatalogId,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateNotNull()]
        [uint64] $RepositoryId,

        [Parameter(ParameterSetName="GroupId", Mandatory)]
        [ValidateNotNull()]
        [int] $GroupId,

        [Parameter(ParameterSetName="DeviceId", Mandatory)]
        [ValidateNotNull()]
        [int[]] $DeviceId
    )
    Try {
        $TargetArray = New-Object System.Collections.ArrayList
        Switch ( $PsCmdlet.ParameterSetName ) {
            DeviceId { 
                $DeviceId | ForEach-Object {
                    $Device = Get-OMEDevice -IpAddress $IpAddress -Headers $Headers -DeviceId $_ 
    
                    $DevTargets = $Device | Select-Object Id
                    $DevType = New-Object PsCustomObject
                    $DevType | Add-Member -MemberType NoteProperty -Name Id -Value $Device.Type -Force
                    $DevType | Add-Member -MemberType NoteProperty -Name Name -Value "DEVICE" -Force
                    $DevTargets | Add-Member -MemberType NoteProperty -Name Type -Value $DevType
                    [Void]$TargetArray.Add($DevTargets)
                }
            }
            GroupId {
                $Group = Get-OMEGroup -IpAddress $IpAddress -Headers $Headers -GroupId $GroupId
                $GrpTargets = $Group | Select-Object Id
                $GrpType = New-Object PsCustomObject
                $GrpType | Add-Member -MemberType NoteProperty -Name Id -Value $Group.TypeId
                $GrpType | Add-Member -MemberType NoteProperty -Name Name -Value "GROUP"
                $GrpTargets | Add-Member -MemberType NoteProperty -Name Type -Value $GrpType
                [Void]$TargetArray.Add($GrpTargets)
            }
        }
    } Catch {
        Throw $_
    }

    $BaselinePayload = @{
					"Name" = $Name;
					"Description" = $Description;
					"CatalogId" = $CatalogId;
					"RepositoryId" = $RepositoryId;
					"DowngradeEnabled" = $true;
					"Is64Bit" = $true;
					"Targets" = $TargetArray

				} | ConvertTo-Json -Depth 6

   
    $BaselineURL = "https://$($IpAddress)/api/UpdateService/Baselines"
    $Body = $BaselinePayload
    Try {
        $Response = Invoke-WebRequest -Uri $BaselineURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $Body
            If ( $Response.StatusCode -eq 201 ) {
                $TaskId = ($Response.Content | ConvertFrom-Json).TaskId

                $i=0
                While ( [String]::IsNullOrEmpty($Object.BaselineId) ) {
                    $i++
                    If ($i -gt 30){ Break }
                    Start-Sleep -s 1
                    $Response = Invoke-WebRequest -Uri $BaselineURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
                    $BaselineInfo = $Response | ConvertFrom-Json
                    Foreach ($Baseline in $BaselineInfo.value) {
                        If ($Baseline.TaskId -eq $TaskId) {
                            $Object = [PsCustomObject] @{
                                Name = [String] $Baseline.Name
                                RepositoryId = [uint64]$Baseline.RepositoryId
                                RepositoryName = [String] $Baseline.RepositoryName
                                CatalogId = [uint64]$Baseline.CatalogId
                                BaselineId = [uint64]$Baseline.Id
                            }
                        }
                    }
                }
            } Else {
                Write-Warning "Baseline creation failed...skipping update"
            }
        Return $Object
    } Catch {
        $_ | ConvertFrom-ErrorJson
    }
}

Export-ModuleMember New-OMEBaseline