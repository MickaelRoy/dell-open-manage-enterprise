Function Wait-OMEJob {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName)]
        [String] $Server = "parg0pome001",

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, Mandatory)]
        [Hashtable] $Headers,

        [Parameter()]
        [String] $Type = "application/json",

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName, Mandatory)]
        [uint64] $JobId,

        [Parameter(Mandatory=$false)]
        [int]$Timeout = 3600,

        [Parameter(Mandatory=$false)]
        [int]$Delay = 10
     )

    $Server = [System.Net.Dns]::GetHostByName($Server).Hostname

    $UpdateJobURL = "https://$Server/api/JobService/Jobs($($JobId))"
    $JobResp = Invoke-WebRequest -Uri $UpdateJobURL -UseBasicParsing -Headers $Headers -ContentType $Type
    $JobInfo = $JobResp.Content | ConvertFrom-Json

    $StatusJobURL = "https://$($Server)$($JobInfo.'ExecutionHistories@odata.navigationLink')"
    $timer =  [Diagnostics.Stopwatch]::StartNew()

    $ArrayList = New-Object System.Collections.Generic.List[hashtable]

        While ( $timer.Elapsed.TotalSeconds -lt $timeout ) {
            Sleep -Seconds $Delay
        
        #Get Global Task details
            $JobStatResp = Invoke-WebRequest -Uri $StatusJobURL -UseBasicParsing -Headers $Headers -ContentType $Type
            $JobStatInfo = ($JobStatResp.Content | ConvertFrom-Json).value
            $Progress = [int]($JobStatInfo.Progress)
            
            If ($Progress -eq 100) {
                Write-Verbose -Message "Job list count $($ArrayList.Count) items"
                Foreach ($Item in $ArrayList) {
                    Write-Progress @Item -Status Ready
                }
                Write-Verbose "Write-Progress -Status Ready -Completed -Id $($JobInfo.Id) -Activity $($JobInfo.JobName)"
                Write-Progress -Status Ready -Completed -Id $JobInfo.Id -Activity $JobInfo.JobName
                break
            }

        #Get Children Tasks details
            $DetailsJobURL = "https://$($Server)$($JobStatInfo.'ExecutionHistoryDetails@odata.navigationLink')"
            $JobDetResp = Invoke-WebRequest -Uri $DetailsJobURL -UseBasicParsing -Headers $Headers -ContentType $Type

            $JobDetails = $JobDetResp.Content | ConvertFrom-Json
            Write-Verbose "Write-Progress -Status $($JobInfo.LastRunStatus.Name) -PercentComplete $Progress -Id $($JobInfo.Id) -Activity $($JobInfo.JobName) -CurrentOperation $($JobInfo.Targets.Id)"
            Write-Progress -Status $JobInfo.LastRunStatus.Name -PercentComplete $Progress -Id $JobInfo.Id -Activity $JobInfo.JobName

            $JobDetails.value | Sort-Object Id | ForEach-Object {
                $Item = [hashtable]@{
                    Id = $_.Id
                    Activity = $_.Key
                    ParentId = $JobInfo.Id
                }
                If ([string]::IsNullOrEmpty( ($ArrayList | Where-Object Id -eq $_.Id) )) {
                    Write-Verbose "Adding $($JobInfo.Id) into the list."
                    [Void]$ArrayList.Add($Item)
                }
                Write-Verbose "Write-Progress -Status $($_.JobStatus.Name) -PercentComplete $($_.Progress) -Id $($_.Id) -Activity $($_.Key) -CurrentOperation $($_.Value.Split("`n")[-1]) -ParentId $($JobInfo.Id)"
                Write-Progress -Status $_.JobStatus.Name -PercentComplete $_.Progress -Id $_.Id -Activity $_.Key -CurrentOperation $_.Value.Split("`n")[-1] -ParentId $JobInfo.Id
            }

        }
        $timer.Stop()
        Write-Verbose -Message "$($timer.Elapsed.Seconds)"
        Write-Progress -Id $JobInfo.Id -Activity $JobInfo.JobName -Status Ready -Completed
        Return $JobStatInfo.JobStatus.Name
}

Export-ModuleMember Wait-OMEJob
